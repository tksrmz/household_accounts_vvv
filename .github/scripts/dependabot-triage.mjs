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
//
// 純粋関数はdependabot-triage.test.mjsで検査する(node --test ".github/scripts/*.test.mjs")。
import { execFileSync } from "node:child_process";
import { appendFileSync, existsSync, statSync } from "node:fs";
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

// 更新前のバージョンはメタデータに無いので、Dependabotが書く定型の文から読む。
// 単体のPRはタイトル(bump x from a to b)、グループのPRは本文(Updates `x` from a to b)にある。
export function parseFromVersions(title, body) {
  const from = {};
  for (const m of (body ?? "").matchAll(/^Updates `([^`]+)` from (\S+) to (\S+)$/gm)) {
    from[m[1]] = m[2];
  }
  const single = /\bbump (\S+) from (\S+) to (\S+)/.exec(title);
  if (single && !(single[1] in from)) from[single[1]] = single[2];
  return from;
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
// 戻り値のactionはmerge / close / comment / skip。
export function planAction(pr, decision) {
  if (!pr) return { action: "skip", why: "判定の対象に集めたPRではない" };
  if (decision.head_sha !== pr.head_sha) return { action: "skip", why: "判定の後にPRの頭のコミットが変わった" };
  switch (decision.decision) {
    case "merge":
      if (pr.ci.state !== "success") {
        return { action: "comment", why: `Claudeはマージと判定したが、CIが成功していない(${pr.ci.state})` };
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

// ---- ここから下はGitHubへの入出力 ----

function gh(args, { input } = {}) {
  return execFileSync("gh", args, { encoding: "utf8", input, stdio: ["pipe", "pipe", "inherit"] });
}

function ghJson(args) {
  return JSON.parse(gh(args));
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
    const message = ghJson(["api", `repos/${repo}/commits/${pr.headRefOid}`]).commit.message;
    const from = parseFromVersions(pr.title, pr.body);
    targets.push({
      number: pr.number,
      title: pr.title,
      head_sha: pr.headRefOid,
      branch: pr.headRefName,
      ecosystem: eco.ecosystem,
      dependencies: parseUpdatedDependencies(message).map((d) => ({ ...d, from: from[d.name] ?? null })),
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

function act() {
  const repo = process.env.GITHUB_REPOSITORY;
  const prs = JSON.parse(process.env.PRS);
  const { decisions = [] } = JSON.parse(process.env.DECISIONS || "{}");
  const toDispatch = new Set();
  summary("## 判定の実行");
  summary("");
  for (const decision of decisions) {
    const pr = prs.find((p) => p.number === decision.number);
    let plan = planAction(pr, decision);
    // 判定の間にDependabotがrebaseしていれば、古いコミットへの判定は使わない
    if (plan.action !== "skip") {
      const live = ghJson(["pr", "view", String(pr.number), "--repo", repo, "--json", "headRefOid,state"]);
      if (live.state !== "OPEN" || live.headRefOid !== pr.head_sha) {
        plan = { action: "skip", why: "判定の後にPRが更新されたか、閉じられた" };
      }
    }
    const reason = [plan.why, decision.reason].filter(Boolean).join("\n\n");
    try {
      switch (plan.action) {
        case "merge":
          gh(["pr", "merge", String(pr.number), "--repo", repo, "--merge", "--match-head-commit", pr.head_sha]);
          for (const w of workflowsToDispatch(pr.branch, pr.files)) toDispatch.add(w);
          break;
        case "close":
          gh(["pr", "close", String(pr.number), "--repo", repo, "--comment", commentBody(reason, pr.head_sha)]);
          break;
        case "comment":
          gh(["pr", "comment", String(pr.number), "--repo", repo, "--body-file", "-"], {
            input: commentBody(reason, pr.head_sha),
          });
          break;
      }
      summary(`- #${decision.number}: ${plan.action}${plan.why ? `(${plan.why})` : ""}`);
    } catch (error) {
      // 1件の失敗(並んだPRのマージで競合した、など)で残りを止めない。Dependabotがrebaseすれば次の実行で拾う
      process.exitCode = 1;
      summary(`- #${decision.number}: ${plan.action}に失敗した: ${error.message}`);
    }
  }
  for (const workflow of toDispatch) {
    gh(["workflow", "run", workflow, "--repo", repo, "--ref", process.env.DEFAULT_BRANCH]);
    summary(`- ${workflow} を起動した(GITHUB_TOKENでのマージではpushのワークフローが動かないため)`);
  }
  const patch = process.env.HOLDS_PATCH;
  if (patch && existsSync(patch) && statSync(patch).size > 0) openHoldsPullRequest(repo, patch, decisions);
}

// 解除の条件を満たした見送りの節を消すPR。前のPRが開いたままなら作らない(重複させない)
function openHoldsPullRequest(repo, patch, decisions) {
  const branch = "automation/dependency-holds";
  const open = ghJson(["pr", "list", "--repo", repo, "--head", branch, "--state", "open", "--json", "url"]);
  if (open.length > 0) {
    summary(`- 見送りの解除: 前のPRが開いたままなので作らなかった(${open[0].url})`);
    return;
  }
  const lifted = decisions.flatMap((d) => (d.lifted_holds ?? []).map((h) => ({ hold: h, pr: d.number })));
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
    ...lifted.map(({ hold, pr }) => `- ${hold}(#${pr} の判定で確かめた)`),
    "",
    "各見送りの「解除の条件」に、解除した後に人が確かめることが書かれていれば、それも確かめてからマージしてください。",
    "GITHUB_TOKENで作ったPRなので、CIは動きません。",
  ].join("\n");
  const url = gh(["pr", "create", "--repo", repo, "--base", process.env.DEFAULT_BRANCH, "--head", branch,
    "--title", "docs: 解除の条件を満たした依存の見送りを消す", "--body-file", "-"], { input: body }).trim();
  summary(`- 見送りの解除のPRを作った: ${url}`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const command = process.argv[2];
  if (command === "collect") collect();
  else if (command === "act") act();
  else throw new Error(`unknown command: ${command}`);
}
