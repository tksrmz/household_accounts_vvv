// dependabot-triage.yml の決まった処理(判定の材料集めと、判定の実行)。
//
// 判定そのもの(見送りに当たるか、解除の条件を満たしたか)はClaudeが読み取り専用の
// ジョブで行い、書き込み(マージ・クローズ・コメント・PR作成・ワークフローの起動)は
// このスクリプトだけが行う。Claudeが読む材料には上流の情報(npmのメタデータやCIのログ)が
// 入るので、Claudeの答えをそのまま信じず、マージはCIが全部成功したPRに限るなど、
// ここで確かめてから実行する。
//
//   node dependabot-triage.mjs collect   判定の対象にするPRを集め、GITHUB_OUTPUTのprsに書く
//   node dependabot-triage.mjs act       環境変数PRSとDECISIONSを受け取り、判定を実行する
//   node dependabot-triage.mjs denials <file>  Claudeの実行記録から、拒否されたツール呼び出しをサマリーに書く
//
// 純粋関数はdependabot-triage.test.mjsで検査する(node --test ".github/scripts/*.test.mjs")。
import { execFileSync } from "node:child_process";
import { appendFileSync, existsSync, readFileSync, statSync } from "node:fs";
import { pathToFileURL } from "node:url";

// 判定を済ませたことを、PRのコメントに頭のコミットごとに残す。同じコミットを二度判定しない
// (人が見るまで残すPRに、実行のたびにClaudeを呼んでコメントを重ねないため)。
export const markerFor = (headSha) => `<!-- dependabot-triage head=${headSha} -->`;

// ブランチ名の接頭辞から、エコシステムとそのPRで必ず走るCIのワークフロー名を決める。
// CIが始まる前(チェックがまだ1つも無い)に「全部成功」と見なさないために、走るはずの
// ワークフローを名前で求める。pr-ci.yml・functions-ci.ymlのpathsを変えたらここも見直す。
//
// github_actionsはGITHUB_TOKENでマージできない(ワークフローのファイルを変えるPRは
// workflows権限が要り、GITHUB_TOKENには付けられない)ので、判定の対象にしない。
const ecosystems = [
  {
    prefix: "dependabot/npm_and_yarn/firebase/functions/",
    ecosystem: "npm (firebase/functions)",
    lockfile: "firebase/functions/package-lock.json",
    requiredWorkflows: ["Functions CI"],
    // 本番のpushで動くワークフロー。GITHUB_TOKENでマージするとpushのワークフローが
    // 動かないので、マージした後にworkflow_dispatchで起動する。
    // 判定はファイルのパスで行う(functions-deploy.ymlのpush.pathsと合わせる)。
    dispatch: [
      {
        workflow: "functions-deploy.yml",
        matches: (path) => path.startsWith("firebase/functions/") || path === "firebase/firebase.json",
      },
    ],
  },
  {
    prefix: "dependabot/pub/",
    ecosystem: "pub",
    lockfile: "pubspec.lock",
    requiredWorkflows: ["PR CI"],
    dispatch: [
      {
        // master-build.ymlのpush.pathsと合わせる
        workflow: "master-build.yml",
        matches: (path) =>
          ["lib/", "android/", "fonts/", ".github/actions/build-release-appbundle/"].some((p) =>
            path.startsWith(p),
          ) || ["pubspec.yaml", "pubspec.lock", "build.yaml", "mise.toml", "mise.lock"].includes(path),
      },
    ],
  },
];

export function ecosystemOf(branch) {
  return ecosystems.find((e) => branch.startsWith(e.prefix)) ?? null;
}

// Dependabotのコミットメッセージ末尾のYAML(dependabot/fetch-metadataが読むのと同じもの)から、
// 更新する依存を読む。
export function parseUpdatedDependencies(commitMessage) {
  const block = /^updated-dependencies:\n([\s\S]*?)^\.\.\.$/m.exec(commitMessage);
  if (!block) return [];
  return block[1]
    .split(/^- /m)
    .filter((entry) => entry.trim() !== "")
    .map((entry) => {
      // スコープ付きのパッケージ名("@typescript-eslint/parser")は引用符で囲まれて書かれる
      const field = (key) =>
        new RegExp(`^\\s*${key}:\\s*(.+)$`, "m").exec(entry)?.[1].trim().replace(/^"(.*)"$/, "$1") ?? null;
      return {
        name: field("dependency-name"),
        to: field("dependency-version"),
        dependencyType: field("dependency-type"),
        updateType: field("update-type"),
      };
    })
    .filter((dep) => dep.name !== null);
}

// Dependabotが書く定型の文から、更新する依存の名前と更新前のバージョンを読む。単体のPRはタイトル
// (bump x from a to b)、グループのPRは本文(Updates `x` from a to b)にある。バージョンの正は
// ロックファイル(lockedVersion)で、ここで読むのはメタデータから漏れた名前を拾うため。
export function parseFromVersions(title, body) {
  const from = {};
  for (const m of (body ?? "").matchAll(/^Updates `([^`]+)` from (\S+) to (\S+)$/gm)) {
    from[m[1]] = m[2];
  }
  const single = /\bbump (\S+) from (\S+) to (\S+)/.exec(title);
  if (single && !(single[1] in from)) from[single[1]] = single[2];
  return from;
}

// 更新前後のバージョンはロックファイルから読む。コミットメッセージのメタデータは、Dependabotが
// PRを作り直してもコミットを作った時点のまま残ることがある(#28では、メタデータはeslint 10.10.0、
// package.jsonは^10.15.0だった)ので、バージョンの正にしない。
export function lockedVersion(lockfileName, lockText, name) {
  if (lockText == null) return null;
  if (lockfileName === "package-lock.json") {
    return JSON.parse(lockText).packages?.[`node_modules/${name}`]?.version ?? null;
  }
  if (lockfileName === "pubspec.lock") {
    // pubspec.lockは packages: の下に2字下げでパッケージ名、4字下げでその属性が並ぶ
    const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const m = new RegExp(`^  ${escaped}:\\n(?:    .*\\n)*?    version: "([^"]+)"`, "m").exec(lockText);
    return m?.[1] ?? null;
  }
  throw new Error(`unknown lockfile: ${lockfileName}`);
}

const passingConclusions = new Set(["SUCCESS", "SKIPPED", "NEUTRAL"]);

// statusCheckRollup(gh pr view --json statusCheckRollup)からCIの状態を決める。
// pending: 走っているか、走るはずのワークフローがまだ無い。failure: どれかが成功以外で終わった。
export function ciStateOf(rollup, requiredWorkflows) {
  const failed = [];
  let pending = false;
  for (const check of rollup) {
    if (check.__typename === "StatusContext") {
      if (check.state === "PENDING" || check.state === "EXPECTED") pending = true;
      else if (check.state !== "SUCCESS") failed.push(check.context);
      continue;
    }
    if (check.status !== "COMPLETED") pending = true;
    else if (!passingConclusions.has(check.conclusion)) {
      failed.push(check.workflowName ? `${check.workflowName} / ${check.name}` : check.name);
    }
  }
  const seen = new Set(rollup.map((c) => c.workflowName).filter(Boolean));
  const missing = requiredWorkflows.filter((w) => !seen.has(w));
  if (pending || missing.length > 0) return { state: "pending", failed, missing };
  return { state: failed.length > 0 ? "failure" : "success", failed, missing };
}

export function workflowsToDispatch(branch, files) {
  const eco = ecosystemOf(branch);
  if (!eco) return [];
  return eco.dispatch.filter((d) => files.some((f) => d.matches(f))).map((d) => d.workflow);
}

// Claudeの判定を、このスクリプトが実行してよい操作に絞る。
// liveは実行の直前に読み直したPRの状態({state, head_sha, ci})。集めた時点の状態では判断しない
// (判定の間にrebaseされたり、同じコミットでCIが再実行されて失敗したりしうるため)。
// 戻り値のactionはmerge / close / comment / skip。
export function planAction(pr, decision, live) {
  if (!pr) return { action: "skip", why: "判定の対象に集めたPRではない" };
  if (decision.head_sha !== pr.head_sha) return { action: "skip", why: "判定の後にPRの頭のコミットが変わった" };
  if (live.state !== "OPEN" || live.head_sha !== pr.head_sha) {
    return { action: "skip", why: "判定の後にPRが更新されたか、閉じられた" };
  }
  switch (decision.decision) {
    case "merge":
      // コメントすると判定済みの印が付き、このコミットは二度と集められない。CIの再実行が
      // 終われば、その完了で起動した実行が今のCIの結果で判定し直すので、ここでは何もしない
      if (live.ci.state !== "success") {
        return { action: "skip", why: `Claudeはマージと判定したが、今のCIが成功していない(${live.ci.state})。次の実行で判定し直す` };
      }
      return { action: "merge" };
    case "close":
      return { action: "close" };
    case "needs_human":
      return { action: "comment" };
    default:
      return { action: "skip", why: `不明な判定: ${decision.decision}` };
  }
}

// Claudeが見送りごとに確かめたこと(checked_holds)を、Markdownの箇条書きにする。
// 判定のログは公開リポジトリでは誰でも読めるので全文を出しておらず、判定の根拠はここで残す。
export function holdCheckLines(checks) {
  return checks.map((c) => `- **${c.heading}**: ${c.lifted ? "解除できる" : "まだ解除できない"}。${c.evidence}`);
}

// PRへのコメントに付ける「確かめたこと」の節。更新する依存はロックファイルから読んだ値(決まった処理)、
// 見送りの確認はClaudeの答え。
export function checkRecordFor(pr, checks) {
  const deps = pr.dependencies.map((d) => `- \`${d.name}\` ${d.from ?? "(なし)"} → ${d.to ?? "(なし)"}`);
  const applying = checks.filter((c) => (c.applies_to_prs ?? []).includes(pr.number));
  return [
    "### 確かめたこと",
    "",
    "更新する依存(既定ブランチとこのPRのロックファイルから読んだ値):",
    "",
    ...(deps.length ? deps : ["- (読めなかった)"]),
    "",
    "当たる見送り(`docs/dependency_holds.md`):",
    "",
    ...(applying.length ? holdCheckLines(applying) : ["- 無かった"]),
  ].join("\n");
}

// 実行記録(claude-code-actionのexecution_file。SDKのメッセージの配列)から、拒否された呼び出しを読む
export function permissionDenials(file) {
  const messages = Array.isArray(file) ? file : (file?.messages ?? []);
  const result = messages.findLast((m) => m.type === "result") ?? null;
  return (result?.permission_denials ?? []).map((d) => {
    const input = d.tool_input?.command ?? d.tool_input?.file_path ?? JSON.stringify(d.tool_input ?? {});
    return { tool: d.tool_name, input: String(input).slice(0, 300) };
  });
}

// ---- ここから下はGitHubへの入出力 ----

function gh(args, { input } = {}) {
  return execFileSync("gh", args, { encoding: "utf8", input, stdio: ["pipe", "pipe", "inherit"] });
}

function ghJson(args) {
  return JSON.parse(gh(args));
}

// ロックファイルは1MBを超えうるので、contents APIのJSON(base64)ではなく生の中身で読む
function readFileAt(repo, path, ref) {
  try {
    return gh(["api", "-H", "Accept: application/vnd.github.raw", `repos/${repo}/contents/${path}?ref=${ref}`]);
  } catch {
    return null;
  }
}

function setOutput(name, value) {
  appendFileSync(process.env.GITHUB_OUTPUT, `${name}<<__EOF__\n${value}\n__EOF__\n`);
}

function summary(line) {
  if (process.env.GITHUB_STEP_SUMMARY) appendFileSync(process.env.GITHUB_STEP_SUMMARY, `${line}\n`);
  console.log(line);
}

function collect() {
  const repo = process.env.GITHUB_REPOSITORY;
  const prs = ghJson([
    "pr", "list", "--repo", repo, "--author", "app/dependabot", "--state", "open", "--limit", "100",
    "--json", "number,title,headRefName,headRefOid,body,statusCheckRollup,files,comments",
  ]);
  const targets = [];
  summary("## 判定の対象");
  summary("");
  for (const pr of prs) {
    const eco = ecosystemOf(pr.headRefName);
    if (!eco) {
      summary(`- #${pr.number}: 対象外(${pr.headRefName}。github-actionsは手でマージする)`);
      continue;
    }
    if (pr.comments.some((c) => c.body.includes(markerFor(pr.headRefOid)))) {
      summary(`- #${pr.number}: このコミットは判定済み`);
      continue;
    }
    const ci = ciStateOf(pr.statusCheckRollup, eco.requiredWorkflows);
    if (ci.state === "pending") {
      summary(`- #${pr.number}: CIの完了待ち${ci.missing.length ? `(未開始: ${ci.missing.join(", ")})` : ""}`);
      continue;
    }
    // 更新する依存の名前は、メタデータと本文の定型文の両方から集める(どちらかが古くても漏らさない)
    const message = ghJson(["api", `repos/${repo}/commits/${pr.headRefOid}`]).commit.message;
    const metadata = parseUpdatedDependencies(message);
    const names = [...new Set([...metadata.map((d) => d.name), ...Object.keys(parseFromVersions(pr.title, pr.body))])];
    const baseLock = readFileAt(repo, eco.lockfile, process.env.DEFAULT_BRANCH);
    const headLock = readFileAt(repo, eco.lockfile, pr.headRefOid);
    const lockName = eco.lockfile.split("/").at(-1);
    targets.push({
      number: pr.number,
      title: pr.title,
      head_sha: pr.headRefOid,
      branch: pr.headRefName,
      ecosystem: eco.ecosystem,
      dependencies: names.map((name) => {
        const meta = metadata.find((d) => d.name === name);
        return {
          name,
          from: lockedVersion(lockName, baseLock, name),
          to: lockedVersion(lockName, headLock, name),
          dependencyType: meta?.dependencyType ?? null,
          updateType: meta?.updateType ?? null,
        };
      }),
      files: pr.files.map((f) => f.path),
      ci,
    });
    summary(`- #${pr.number}: 判定する(CI: ${ci.state})`);
  }
  setOutput("prs", JSON.stringify(targets));
  setOutput("count", String(targets.length));
}

function commentBody(text, headSha) {
  return [
    text,
    "",
    "---",
    "_このコメントは `.github/workflows/dependabot-triage.yml` が書きました(判定はClaude、実行はワークフロー)。_",
    markerFor(headSha),
  ].join("\n");
}

function livePr(repo, number) {
  const pr = ghJson(["pr", "view", String(number), "--repo", repo, "--json", "headRefName,headRefOid,state,statusCheckRollup"]);
  const eco = ecosystemOf(pr.headRefName);
  return {
    state: pr.state,
    head_sha: pr.headRefOid,
    ci: eco ? ciStateOf(pr.statusCheckRollup, eco.requiredWorkflows) : { state: "pending", failed: [], missing: [] },
  };
}

function act() {
  const repo = process.env.GITHUB_REPOSITORY;
  const prs = JSON.parse(process.env.PRS || "[]");
  const {
    decisions = [],
    lifted_holds: liftedHolds = [],
    checked_holds: checkedHolds = [],
  } = JSON.parse(process.env.DECISIONS || "{}");
  const toDispatch = new Set();
  summary("## 見送りの確認");
  summary("");
  for (const line of checkedHolds.length ? holdCheckLines(checkedHolds) : ["- (記録が無い)"]) summary(line);
  summary("");
  summary("## 判定の実行");
  summary("");
  try {
    for (const decision of decisions) {
      // 1件の失敗(読み直しの失敗、並んだPRのマージの競合など)で残りを止めない。
      // Dependabotがrebaseすれば次の実行で拾う
      try {
        actOn(repo, prs, decision, toDispatch, checkedHolds);
      } catch (error) {
        process.exitCode = 1;
        summary(`- #${decision.number}: 失敗した: ${error.message}`);
      }
    }
  } finally {
    // マージしたPRは次の実行で集められないので、起動し損ねると取り返せない。何が失敗しても起動する
    for (const workflow of toDispatch) {
      try {
        gh(["workflow", "run", workflow, "--repo", repo, "--ref", process.env.DEFAULT_BRANCH]);
        summary(`- ${workflow} を起動した(GITHUB_TOKENでのマージではpushのワークフローが動かないため)`);
      } catch (error) {
        process.exitCode = 1;
        summary(`- ::error::${workflow} の起動に失敗した。手で起動すること: ${error.message}`);
      }
    }
  }
  const patch = process.env.HOLDS_PATCH;
  if (patch && existsSync(patch) && statSync(patch).size > 0) openHoldsPullRequest(repo, patch, liftedHolds);
}

function actOn(repo, prs, decision, toDispatch, checkedHolds) {
  const pr = prs.find((p) => p.number === decision.number);
  const plan = planAction(pr, decision, pr ? livePr(repo, pr.number) : null);
  const reason = [plan.why, decision.reason].filter(Boolean).join("\n\n");
  const comment = (text) =>
    gh(["pr", "comment", String(pr.number), "--repo", repo, "--body-file", "-"], {
      input: commentBody(`${text}\n\n${checkRecordFor(pr, checkedHolds)}`, pr.head_sha),
    });
  switch (plan.action) {
    case "merge":
      gh(["pr", "merge", String(pr.number), "--repo", repo, "--merge", "--match-head-commit", pr.head_sha]);
      // 起動はコメントより先に積む(コメントが失敗しても、マージしたPRのワークフローは起動する)
      for (const w of workflowsToDispatch(pr.branch, pr.files)) toDispatch.add(w);
      // マージの後に書く。先に書くと、マージが失敗したときに判定済みの印だけが残り、次の実行で拾えない
      comment(`マージしました。${reason}`);
      break;
    case "close":
      // クローズの前に書く(閉じたPRにも書けるが、通知で理由が先に届くように)
      comment(reason);
      gh(["pr", "close", String(pr.number), "--repo", repo]);
      break;
    case "comment":
      comment(reason);
      break;
  }
  summary(`- #${decision.number}: ${plan.action}${plan.why ? `(${plan.why})` : ""}`);
}

function reportDenials(file) {
  const denials = permissionDenials(JSON.parse(readFileSync(file, "utf8")));
  summary("## 拒否されたツール呼び出し");
  summary("");
  if (denials.length === 0) summary("- 無かった");
  // 拒否されたまま判定したなら、判定の根拠が足りていないかもしれない。警告にして目に付くようにする
  for (const d of denials) {
    summary(`- ${d.tool}: \`${d.input.replaceAll("`", "'")}\``);
    console.log(`::warning::Claudeの${d.tool}の呼び出しが拒否された: ${d.input}`);
  }
}

// 解除の条件を満たした見送りの節を消すPR。前のPRが開いたままなら作らない(重複させない)
function openHoldsPullRequest(repo, patch, liftedHolds) {
  const branch = "automation/dependency-holds";
  const open = ghJson(["pr", "list", "--repo", repo, "--head", branch, "--state", "open", "--json", "url"]);
  if (open.length > 0) {
    summary(`- 見送りの解除: 前のPRが開いたままなので作らなかった(${open[0].url})`);
    return;
  }
  const git = (...args) => execFileSync("git", args, { stdio: "inherit" });
  git("checkout", "-B", branch);
  git("apply", patch);
  git("add", "docs/dependency_holds.md");
  git("-c", "user.name=github-actions[bot]", "-c", "user.email=41898282+github-actions[bot]@users.noreply.github.com",
    "commit", "-m", "docs: 解除の条件を満たした依存の見送りを消す");
  git("push", "--force", "origin", branch);
  const body = [
    "`dependabot-triage.yml` が、`docs/dependency_holds.md` の見送りのうち解除の条件を満たしたものを消しました。",
    "",
    ...liftedHolds.map(({ heading, evidence }) => `- **${heading}**: ${evidence}`),
    "",
    "各見送りの「解除の条件」に、解除した後に人が確かめることが書かれていれば、それも確かめてからマージしてください。",
    "GITHUB_TOKENで作ったPRなので、CIは動きません。",
  ].join("\n");
  const url = gh(["pr", "create", "--repo", repo, "--base", process.env.DEFAULT_BRANCH, "--head", branch,
    "--title", "docs: 解除の条件を満たした依存の見送りを消す", "--body-file", "-"], { input: body }).trim();
  summary(`- 見送りの解除のPRを作った: ${url}`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const command = process.argv[2];
  if (command === "collect") collect();
  else if (command === "act") act();
  else if (command === "denials") reportDenials(process.argv[3]);
  else throw new Error(`unknown command: ${command}`);
}
