# ADR-001: Cloud Functions for FirebaseのランタイムにはNode.js 22を使う

## タイトル

Cloud Functions for FirebaseのランタイムにはNode.js 22を使う

## ステータス

承認済み

## コンテキスト

(事実は2026-11-21に確かめたもの)

### 既存の関数は1st genのAuthトリガーである

- Cloud Functionsは `onCreateUser` の1本だけで、`firebase-functions/v1` の `auth.user().onCreate` を使う1st genの関数である(`firebase/functions/src/index.ts`。リージョンは `asia-northeast2`)
- ユーザーの新規登録をきっかけに `publicProfiles`・`personalNotes`・`privateProfiles` の3ドキュメントを作る。アプリはこのドキュメントがある前提で動くので、この関数が止まると新規ユーザーがアプリを使えない

### Node.js 24以降は2nd gen(Cloud Run functions)でしか使えない

[Google CloudのNode.jsランタイム対応表](https://docs.cloud.google.com/functions/docs/runtime-support)は次のとおり。

| ランタイム | 世代 | 非推奨 | 廃止 |
|---|---|---|---|
| Node.js 24 | Run functions のみ | 2028-04-30 | 2028-10-31 |
| Node.js 22 | 1st gen, Run functions | 2027-04-30 | 2027-10-31 |
| Node.js 20 | 1st gen, Run functions | 2026-04-30 | 2026-10-30 |

1st genのまま選べる最新はNode.js 22である。なお「Node.js 24は1st genで使えない」は、この表の世代の列にNode.js 24だけ「1st gen」が無いことからの読み取りで、そう明記した文章は見つけていない。

### 2nd genの相当トリガーはまだPreviewである

- 2nd genにも `firebase-functions/v2/identity` の `onUserCreated` があり、firebase-functions 7.4.0から公開APIになった
- ただし公式ドキュメントはどれもPreview扱いである
  - [Eventarcの対応イベント一覧](https://docs.cloud.google.com/eventarc/docs/reference/supported-events): 「Firebase Authentication (preview)」
  - [Authトリガーのガイド](https://firebase.google.com/docs/functions/auth-events): Previewの注記がある
  - [APIリファレンス](https://firebase.google.com/docs/reference/functions/2nd-gen/node/firebase-functions.identity): 「(BETA)」と書かれ、本文に「Do not use this API in a production environment」とある
- firebase-functions v7.4.0のリリースノートだけは「general availability」と書いているが、同じ版の型定義のJSDocは `@beta` のままで、公式ドキュメントとも食い違う。公式ドキュメントの記述を正とした
- 1st genの関数を同じ名前のまま2nd genへ上書きすることはできない([アップグレード手順](https://firebase.google.com/docs/functions/2nd-gen-upgrade))。新しい名前で2nd genの関数を追加し、両方を動かしてから1st genを消す。Node.jsのバージョンはコードベースのすべての関数で共通なので、両方が動いている間はNode.js 22のままになる
- ほかの手段として、ブロッキング関数(`beforeUserCreated`)は2nd genでも使える。しかしFirebase Authentication with Identity Platformへのアップグレードが必要なうえ、登録の前に同期で動き、7秒以内に応答しないと登録そのものが失敗する。登録後に初期データを作る今の役割には合わない

### 本番が廃止済みのランタイムで動いていた

- `package.json` の `engines.node` は2026-07に22へ変えていたが、本番には反映されておらず、本番の `onCreateUser` は2026-11-21まで、廃止済み(2026-10-30)のnodejs20で動いていた
- 廃止されたランタイムのままでは作成も再デプロイもできず、既存の関数が無効にされることがある([ランタイム対応表のライフサイクル](https://docs.cloud.google.com/functions/docs/runtime-support))
- 2026-11-21にfirebase-functions 7.4.0・Node.js 22で本番へ再デプロイし、nodejs22になったことを確かめた

## 決定

Cloud Functions for Firebaseは1st genの `auth.user().onCreate` を使い続け、ランタイムにはNode.js 22を使う。

理由:

- Node.js 24以降を使うには2nd genへ移るしかないが、2nd genの相当トリガー(`onUserCreated`)は公式ドキュメント上Previewで、本番での利用を避けるよう書かれている。新規ユーザーの初期データ作成は止まると致命的な処理なので、後方互換のない変更が入りうるPreviewの機能には載せない
- ブロッキング関数は前提(Identity Platform)と性質(同期・7秒制限)が今の役割に合わない
- Node.js 22は1st genで選べる最新で、廃止まで(2027-10-31)に1年近くある。それまでに2nd genの相当トリガーがGAになるのを待ってから移行すればよい

## 影響

- Node.js 24以降の機能は使えない。Node.js 24以上を要求するライブラリが出ても、このADRが有効な間は取り込めない
- ローカル・CIを含む開発環境もNode.js 22に揃える必要がある(`devEngines` と `engine-strict` により、22以外ではインストール・ビルド・デプロイが失敗する)
- **Node.js 22の非推奨(2027-04-30)までに、このADRを見直す**。見直しの時点で2nd genの `onUserCreated` がGAになっていれば、次の順で移行し、その決定を新しいADRに書いてこのADRを破棄にする
  1. Node.js 22のまま、2nd genの関数を新しい名前で追加してデプロイし、新規登録で3ドキュメントが作られることを確かめる(1st genと両方が動く間は1件の登録で2回処理が走るが、`batch.create` は既存のドキュメントがあると失敗するのでデータは二重にならない)
  2. 1st genの `onCreateUser` をソースから消してデプロイする
  3. Node.js 24以降へ上げて再デプロイする
- 移行のときに一緒に直すもの: 単体テスト(firebase-functions-testには2nd genのAuthイベントのモック生成がないので、イベントの中身を自分で渡す)、2nd genの実行サービスアカウント(Compute Engineの既定)のFirestore書き込み権限、`integration_test/README.md`・`CLAUDE.md`・`mise.toml` のNode.jsの記述
- 2nd genのAuthトリガーをFunctionsエミュレータで動かすにはfirebase-tools 15.34.1以上が要る(15.30.2で動作、15.34.1でイベントの形式を修正)。2026-11-21時点で `mise.toml` は15.37.0なので満たしている

## コンプライアンス

守りたい状態ごとに、次の仕組みで確かめる。

- **デプロイするとNode.js 22・1st genになること(ソースの宣言)**: [`docs/adr/checks/001-firebase-functions-node22.test.mjs`](./checks/001-firebase-functions-node22.test.mjs) が確かめ、`adr-compliance.yml` が全PRで走らせる。確かめる内容は次のとおり
  - `firebase/functions/package.json` の `engines.node` が `"22"`
  - `firebase/firebase.json` の `functions` に `runtime` が無い(書くと `engines.node` より優先される)
  - リポジトリ直下の `mise.toml` の `node` が22系(開発環境とCIのNode.js)
  - 関数のソースが `firebase-functions/v1` だけをimportしている(パッケージ直下の `firebase-functions` は2nd genのAPIを指す)
- **本番が実際にNode.js 22・1st genであること**: `engines.node` を変えただけでは本番は変わらない(本番がnodejs20のまま残っていた原因)。そこでデプロイは `functions-deploy.yml` がmasterへのマージをきっかけに行い、デプロイの直後に [`docs/adr/checks/001-firebase-functions-node22.production.mjs`](./checks/001-firebase-functions-node22.production.mjs) で、本番のすべての関数が `gcfv1` かつ `nodejs22` であることを確かめる。手順と前提の設定は [functions_deploy.md](../functions_deploy.md) にある(2026-11-23時点で前提の設定は未了で、CIからのデプロイはまだ一度も成功していない。最初のデプロイが成功したら、この注記を消す)
- **見直しの期限(2027-04-30)に気づくこと**: 期限を設定したIssueで管理する(2026-11-23時点で未作成。作ったらIssueへのリンクをここに書く)
