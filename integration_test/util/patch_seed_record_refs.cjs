// integration_test/saved-data の一回きり修正スクリプト(2026-08-24実施、再現手段として保存)。
//
// シードレコードの property.ref / category.ref が文字列パスで保存されており、
// 本番の正(アプリはDocumentReferenceを書き込み、firestore.rulesも `is path` を要求する)と
// 乖離していたため、Firestoreエミュレータ上で referenceValue へ変換した。
// 文字列refはルール上アプリから書き込めない形であり、エミュレータのimportが
// ルールを迂回するためシードにだけ存在できていた。
//
// 使い方(firebase/ ディレクトリから):
//   firebase emulators:exec --project household-accounts-1129d --only auth,firestore \
//     --import ../integration_test/saved-data --export-on-exit ../integration_test/saved-data \
//     "node ../integration_test/util/patch_seed_record_refs.cjs"
//
// CommonJS(.cjs)なのは、firebase-toolsのスタンドアロンバイナリが子プロセスの
// `node` を同梱のNode(pkg、requireロード)で解決し、.mjsを実行できないため。
const PID = 'household-accounts-1129d';
const BASE = `http://localhost:8081/v1/projects/${PID}/databases/(default)/documents`;
const HEADERS = { Authorization: 'Bearer owner' };
const notes = [
  'personalNotes/fmVfCNkA2wGfJx69LRFhl3ird9EB',
  'sharedNotes/fQXxUXlNqXLIQx80TsEd',
];
const collections = ['incomes', 'expenses', 'transfers'];
const refFields = ['property', 'category', 'fromProperty', 'toProperty'];

async function main() {
  let patched = 0;
  let untouched = 0;
  for (const note of notes) {
    for (const col of collections) {
      const res = await fetch(`${BASE}/${note}/${col}?pageSize=300`, {
        headers: HEADERS,
      });
      if (!res.ok) {
        throw new Error(
          `list failed: ${note}/${col} -> ${res.status} ${await res.text()}`,
        );
      }
      const { documents = [] } = await res.json();
      for (const doc of documents) {
        const fields = doc.fields ?? {};
        const updates = {};
        for (const field of refFields) {
          const ref =
            fields[field] &&
            fields[field].mapValue &&
            fields[field].mapValue.fields &&
            fields[field].mapValue.fields.ref;
          if (ref && ref.stringValue) {
            updates[field] = {
              mapValue: {
                fields: {
                  ref: {
                    referenceValue: `projects/${PID}/databases/(default)/documents${ref.stringValue}`,
                  },
                },
              },
            };
          }
        }
        if (Object.keys(updates).length === 0) {
          untouched++;
          continue;
        }
        const mask = Object.keys(updates)
          .map((k) => `updateMask.fieldPaths=${k}`)
          .join('&');
        const res2 = await fetch(`http://localhost:8081/v1/${doc.name}?${mask}`, {
          method: 'PATCH',
          headers: { ...HEADERS, 'Content-Type': 'application/json' },
          body: JSON.stringify({ fields: updates }),
        });
        if (!res2.ok) {
          throw new Error(
            `patch failed: ${doc.name} -> ${res2.status} ${await res2.text()}`,
          );
        }
        patched++;
      }
    }
  }
  console.log(`patched=${patched} untouched=${untouched}`);
  if (patched === 0) {
    throw new Error(
      '変換対象が1件もありません(既に変換済みか、パス指定の誤り)',
    );
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
