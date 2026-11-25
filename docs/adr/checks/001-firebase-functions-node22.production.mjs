// ADR-001(docs/adr/001-firebase-functions-node22.md)のコンプライアンス検査のうち、
// 本番の状態を確かめるもの。functions-deploy.ymlがデプロイの直後に実行する。
//
// 使い方(firebase/ ディレクトリで):
//   npx firebase-tools@<version> functions:list --project production --json \
//     | node ../docs/adr/checks/001-firebase-functions-node22.production.mjs
//
// 期待するランタイムはfirebase/functions/package.jsonのengines.nodeから求める。
// engines.nodeがADR-001の値であることは001-firebase-functions-node22.test.mjsが確かめている。
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const expectedFunctions = ["onCreateUser"];

const { engines } = JSON.parse(
  readFileSync(fileURLToPath(new URL("../../../firebase/functions/package.json", import.meta.url)), "utf8"),
);
const expectedRuntime = `nodejs${engines.node}`;

const output = JSON.parse(readFileSync(0, "utf8"));
if (output.status !== "success" || !Array.isArray(output.result)) {
  console.error(`functions:list の出力が想定と違う: ${JSON.stringify(output)}`);
  process.exit(1);
}

const problems = [];
for (const name of expectedFunctions) {
  if (!output.result.some((fn) => fn.id === name)) {
    problems.push(`${name} が本番に無い`);
  }
}
for (const fn of output.result) {
  // gcfv1 が1st gen、gcfv2 が2nd gen
  if (fn.platform !== "gcfv1") {
    problems.push(`${fn.id} の世代が ${fn.platform} (期待: gcfv1)`);
  }
  if (fn.runtime !== expectedRuntime) {
    problems.push(`${fn.id} のランタイムが ${fn.runtime} (期待: ${expectedRuntime})`);
  }
}

if (problems.length > 0) {
  console.error(`本番がADR-001に沿っていない:\n- ${problems.join("\n- ")}`);
  process.exit(1);
}
console.log(
  `本番はADR-001に沿っている: ${output.result.map((fn) => `${fn.id}(${fn.platform}, ${fn.runtime})`).join(", ")}`,
);
