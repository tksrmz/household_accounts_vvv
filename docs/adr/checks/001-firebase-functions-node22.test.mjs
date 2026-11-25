// ADR-001(docs/adr/001-firebase-functions-node22.md)のコンプライアンス検査のうち、
// リポジトリのファイルだけで確かめられるもの。adr-compliance.ymlが全PRで実行する。
// 本番が実際にNode.js 22・1st genであることは、functions-deploy.ymlがデプロイ直後に
// 001-firebase-functions-node22.production.mjsで確かめる。
//
// ADR-001を破棄して新しいADRに置き換えるときは、このファイルも新しいADRに合わせて
// 書き換えるか消す。
import { strict as assert } from "node:assert";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

// ADR-001が決めたNode.jsのメジャーバージョン
const requiredNodeMajor = "22";

const repoRoot = fileURLToPath(new URL("../../../", import.meta.url));
const functionsDir = join(repoRoot, "firebase", "functions");

function readRepoFile(...segments) {
  return readFileSync(join(repoRoot, ...segments), "utf8");
}

test("デプロイ時のランタイムを決めるengines.nodeがADR-001のNode.jsのメジャーであること", () => {
  const { engines } = JSON.parse(readRepoFile("firebase", "functions", "package.json"));
  assert.equal(engines?.node, requiredNodeMajor);
});

test("firebase.jsonのfunctionsがruntimeを持たず、engines.nodeを上書きしないこと", () => {
  const { functions } = JSON.parse(readRepoFile("firebase", "firebase.json"));
  // functionsはコードベースが1つなら1つのオブジェクト、複数なら配列で書ける
  const codebases = Array.isArray(functions) ? functions : [functions];
  for (const codebase of codebases) {
    assert.equal(codebase?.runtime, undefined, `runtimeが書かれている: ${JSON.stringify(codebase)}`);
  }
});

test("開発環境とCIのNode.js(mise.tomlのnode)がADR-001のNode.jsのメジャーであること", () => {
  const match = /^node\s*=\s*"(\d+)[^"]*"/m.exec(readRepoFile("mise.toml"));
  assert.ok(match, "mise.tomlにnodeのバージョンが見つからない");
  assert.equal(match[1], requiredNodeMajor);
});

test("関数がfirebase-functions/v1(1st gen)だけを使い、2nd genのAPIを使わないこと", () => {
  // firebase-functionsのパッケージ直下("firebase-functions")は、v4以降は2nd genのAPIを指す
  const importPattern = /from\s+["'](firebase-functions(?:\/[^"']*)?)["']/g;
  const sources = readdirSync(join(functionsDir, "src"), { recursive: true })
    .filter((path) => /\.[cm]?[jt]s$/.test(path));
  assert.ok(sources.length > 0, "firebase/functions/src にソースが無い");

  const specifiers = sources.flatMap((path) =>
    [...readFileSync(join(functionsDir, "src", path), "utf8").matchAll(importPattern)]
      .map((match) => ({ path, specifier: match[1] }))
  );
  assert.ok(specifiers.length > 0, "firebase-functionsのimportが見つからない");
  for (const { path, specifier } of specifiers) {
    assert.match(specifier, /^firebase-functions\/v1(\/|$)/, `${path} が ${specifier} をimportしている`);
  }
});
