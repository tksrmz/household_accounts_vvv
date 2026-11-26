// dependabot-triage.mjs の純粋関数の検査。実行: node --test ".github/scripts/*.test.mjs"
import { strict as assert } from "node:assert";
import { test } from "node:test";
import {
  checkRecordFor,
  ciStateOf,
  holdCheckLines,
  ecosystemOf,
  lockedVersion,
  markerFor,
  parseFromVersions,
  parseUpdatedDependencies,
  permissionDenials,
  planAction,
  workflowsToDispatch,
} from "./dependabot-triage.mjs";

// #28の頭のコミットのメッセージ(抜粋)
const groupCommitMessage = `chore: bump the development-minor-and-patch group across 1 directory with 2 updates

---
updated-dependencies:
- dependency-name: "@typescript-eslint/parser"
  dependency-version: 8.69.0
  dependency-type: direct:development
  update-type: version-update:semver-minor
  dependency-group: development-minor-and-patch
- dependency-name: eslint
  dependency-version: 10.10.0
  dependency-type: direct:development
  update-type: version-update:semver-minor
  dependency-group: development-minor-and-patch
...

Signed-off-by: dependabot[bot] <support@github.com>
`;

const checkRun = (workflowName, name, status, conclusion) => ({
  __typename: "CheckRun", workflowName, name, status, conclusion,
});

test("Dependabotのコミットメッセージのとき、引用符を外した名前・新しいバージョン・更新の種類が読めること", () => {
  assert.deepEqual(parseUpdatedDependencies(groupCommitMessage), [
    { name: "@typescript-eslint/parser", to: "8.69.0", dependencyType: "direct:development", updateType: "version-update:semver-minor" },
    { name: "eslint", to: "10.10.0", dependencyType: "direct:development", updateType: "version-update:semver-minor" },
  ]);
});

test("メタデータの無いコミットメッセージのとき、更新する依存が空であること", () => {
  assert.deepEqual(parseUpdatedDependencies("fix: something"), []);
});

test("単体のPRはタイトルから、グループのPRは本文から更新前のバージョンが読めること", () => {
  assert.deepEqual(parseFromVersions("chore: bump typescript from 6.0.3 to 7.0.2 in /firebase/functions", ""), {
    typescript: "6.0.3",
  });
  assert.deepEqual(
    parseFromVersions("chore: bump the pub group", "Bumps ...\n\nUpdates `freezed` from 4.0.1 to 4.0.3\n<details>"),
    { freezed: "4.0.1" },
  );
});

test("ブランチ名の接頭辞でエコシステムが決まり、github-actionsは対象外であること", () => {
  assert.equal(ecosystemOf("dependabot/npm_and_yarn/firebase/functions/typescript-7.0.2").requiredWorkflows[0], "Functions CI");
  assert.equal(ecosystemOf("dependabot/pub/pub-minor-and-patch-9a9f70a314").requiredWorkflows[0], "PR CI");
  assert.equal(ecosystemOf("dependabot/github_actions/actions/checkout-8"), null);
});

test("走るはずのワークフローが全部成功し、それ以外がスキップのとき、CIは成功であること", () => {
  const rollup = [
    checkRun("Functions CI", "build", "COMPLETED", "SUCCESS"),
    checkRun("ADR Compliance", "check", "COMPLETED", "SUCCESS"),
    checkRun("Claude Code Review", "claude-review", "COMPLETED", "SKIPPED"),
  ];
  assert.equal(ciStateOf(rollup, ["Functions CI"]).state, "success");
});

test("走るはずのワークフローがまだ無いとき、ほかが成功していてもCIは完了待ちであること", () => {
  const rollup = [checkRun("ADR Compliance", "check", "COMPLETED", "SUCCESS")];
  assert.deepEqual(ciStateOf(rollup, ["PR CI"]), { state: "pending", failed: [], missing: ["PR CI"] });
});

test("どれかが走っている間は、別のチェックが失敗していてもCIは完了待ちであること", () => {
  const rollup = [
    checkRun("PR CI", "check", "COMPLETED", "FAILURE"),
    checkRun("PR CI", "golden", "IN_PROGRESS", null),
  ];
  assert.equal(ciStateOf(rollup, ["PR CI"]).state, "pending");
});

test("全部が終わり、どれかが成功以外で終わったとき、CIは失敗で、失敗したチェックの名前が並ぶこと", () => {
  const rollup = [
    checkRun("PR CI", "check", "COMPLETED", "FAILURE"),
    checkRun("PR CI", "golden", "COMPLETED", "CANCELLED"),
    { __typename: "StatusContext", context: "external", state: "SUCCESS" },
  ];
  assert.deepEqual(ciStateOf(rollup, ["PR CI"]), {
    state: "failure", failed: ["PR CI / check", "PR CI / golden"], missing: [],
  });
});

test("マージしたPRが変えたファイルに合わせて、pushで動くはずだったワークフローを起動すること", () => {
  assert.deepEqual(
    workflowsToDispatch("dependabot/npm_and_yarn/firebase/functions/x", ["firebase/functions/package.json"]),
    ["functions-deploy.yml"],
  );
  assert.deepEqual(workflowsToDispatch("dependabot/pub/x", ["pubspec.yaml", "pubspec.lock"]), ["master-build.yml"]);
  assert.deepEqual(workflowsToDispatch("dependabot/pub/x", ["packages/household_lints/pubspec.lock"]), []);
});

const pr = { number: 5, head_sha: "abc", ci: { state: "success" } };
const live = (ciState, { state = "OPEN", head_sha = "abc" } = {}) => ({ state, head_sha, ci: { state: ciState } });
const decide = (decision, head_sha = "abc") => ({ number: 5, head_sha, decision });

test("今のCIが成功しているPRをClaudeがマージと判定したとき、マージすること", () => {
  assert.deepEqual(planAction(pr, decide("merge"), live("success")), { action: "merge" });
});

test("集めた時点では成功していたが、今のCIが失敗か実行中のとき、判定済みの印を残さず次の実行に回すこと", () => {
  assert.equal(planAction(pr, decide("merge"), live("failure")).action, "skip");
  assert.equal(planAction(pr, decide("merge"), live("pending")).action, "skip");
});

test("見送りに当たる判定はクローズ、人が見る判定はコメントになること", () => {
  assert.equal(planAction(pr, decide("close"), live("failure")).action, "close");
  assert.equal(planAction(pr, decide("needs_human"), live("failure")).action, "comment");
});

test("集めていないPR・判定の後に更新されたか閉じられたPR・不明な判定のとき、何もしないこと", () => {
  assert.equal(planAction(undefined, decide("merge"), null).action, "skip");
  assert.equal(planAction(pr, decide("merge", "def"), live("success")).action, "skip");
  assert.equal(planAction(pr, decide("merge"), live("success", { head_sha: "def" })).action, "skip");
  assert.equal(planAction(pr, decide("merge"), live("success", { state: "CLOSED" })).action, "skip");
  assert.equal(planAction(pr, decide("approve"), live("success")).action, "skip");
});

test("package-lock.jsonのとき、スコープ付きのパッケージも含めて入っているバージョンが読めること", () => {
  const lock = JSON.stringify({
    packages: {
      "": { devDependencies: { eslint: "^10.15.0" } },
      "node_modules/eslint": { version: "10.15.0" },
      "node_modules/@typescript-eslint/parser": { version: "8.73.0" },
    },
  });
  assert.equal(lockedVersion("package-lock.json", lock, "eslint"), "10.15.0");
  assert.equal(lockedVersion("package-lock.json", lock, "@typescript-eslint/parser"), "8.73.0");
  assert.equal(lockedVersion("package-lock.json", lock, "globals"), null);
});

test("pubspec.lockのとき、そのパッケージの節のバージョンだけが読めること", () => {
  const lock = `packages:
  build:
    dependency: transitive
    description:
      name: build
      url: "https://pub.dev"
    source: hosted
    version: "5.0.0"
  build_runner:
    dependency: "direct dev"
    description:
      name: build_runner
      url: "https://pub.dev"
    source: hosted
    version: "2.17.1"
sdks:
  dart: ">=3.9.0 <4.0.0"
`;
  assert.equal(lockedVersion("pubspec.lock", lock, "build_runner"), "2.17.1");
  assert.equal(lockedVersion("pubspec.lock", lock, "build"), "5.0.0");
  assert.equal(lockedVersion("pubspec.lock", lock, "freezed"), null);
});

test("ロックファイルが読めなかったとき、バージョンは不明(null)であること", () => {
  assert.equal(lockedVersion("pubspec.lock", null, "build"), null);
});

test("判定済みの印は頭のコミットごとに別であること", () => {
  assert.notEqual(markerFor("abc"), markerFor("def"));
  assert.match(markerFor("abc"), /^<!-- .* -->$/);
});

const checks = [
  { heading: "typescript >=7.0.0", applies_to_prs: [5], lifted: false, evidence: "eslint-pluginのpeerは >=4.8.4 <6.1.0" },
  { heading: "firebase-admin >=14.0.0", applies_to_prs: [], lifted: true, evidence: "firebase-functions-testのpeerに ^14.0.0 が入った" },
];

test("見送りの確認は、解除できるかどうかと根拠を見出しごとに1行で並べること", () => {
  assert.deepEqual(holdCheckLines(checks), [
    "- **typescript >=7.0.0**: まだ解除できない。eslint-pluginのpeerは >=4.8.4 <6.1.0",
    "- **firebase-admin >=14.0.0**: 解除できる。firebase-functions-testのpeerに ^14.0.0 が入った",
  ]);
});

test("PRのコメントには、そのPRの依存の更新前後と、そのPRに当たる見送りの確認だけが入ること", () => {
  const record = checkRecordFor(
    { number: 5, dependencies: [{ name: "typescript", from: "6.0.3", to: "7.0.2" }] },
    checks,
  );
  assert.match(record, /- `typescript` 6\.0\.3 → 7\.0\.2/);
  assert.match(record, /typescript >=7\.0\.0\*\*: まだ解除できない/);
  assert.doesNotMatch(record, /firebase-admin/);
});

test("当たる見送りが無く、ロックファイルにも無い依存のとき、そう書くこと", () => {
  const record = checkRecordFor({ number: 7, dependencies: [{ name: "eslint", from: null, to: "10.15.0" }] }, checks);
  assert.match(record, /- `eslint` \(なし\) → 10\.15\.0/);
  assert.match(record, /- 無かった/);
});

test("実行記録の最後の結果から、拒否されたツールとコマンドが読めること", () => {
  const messages = [
    { type: "system", subtype: "init" },
    {
      type: "result",
      permission_denials: [
        { tool_name: "Bash", tool_use_id: "a", tool_input: { command: "npx --yes semver@7.7.2 14.5.1 --range '^13 || ^14'" } },
        { tool_name: "Write", tool_use_id: "b", tool_input: { file_path: "/tmp/x" } },
      ],
    },
  ];
  assert.deepEqual(permissionDenials(messages), [
    { tool: "Bash", input: "npx --yes semver@7.7.2 14.5.1 --range '^13 || ^14'" },
    { tool: "Write", input: "/tmp/x" },
  ]);
  assert.deepEqual(permissionDenials([{ type: "result" }]), []);
});
