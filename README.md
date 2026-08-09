# household_accouts_firebase

[household_accounts](https://github.com/tksrmz/household_accounts)(Flutter製家計簿アプリ)のFirebaseバックエンド。
Cloud Functions / Firestore(ルール・インデックス)/ Hosting の構成を管理する。

## ローカルでのテスト実行

functions のテストは **onlineモード**で動く。実際に dev プロジェクト
(`household-accounts-dev-15106`)の Firestore に書き込み、後始末まで行う統合テストである。

### 前提(初回のみ)

Node.js 22.12.0以上22系未満を使用する。

認証は **ADC (Application Default Credentials)** を標準とする。
サービスアカウントキーのファイルは使わない(常置される無期限キーを廃止するため)。

1. [gcloud CLI](https://cloud.google.com/sdk/docs/install) をインストールする
2. dev プロジェクトへのアクセス権を持つアカウントでADCを設定する:

   ```sh
   gcloud auth application-default login
   ```

認証エラー(`Could not load the default credentials`)が出たら、上記コマンドの再実行で解消する。

### 実行

```sh
cd functions
npm ci
npm test
```

補足:

- テストランナーにはESMをネイティブに扱えるVitestを使用する。
- 環境変数 `HOUSEHOLD_ACCOUNTS_DEV_SERVICE_ACCOUNT_KEY` にサービスアカウントキーのパスを
  設定すると、ADCの代わりにそちらが使われる(上書き用・通常は不要)

## テスト戦略(3層構成)

| 層 | テスト方式 | 認証 |
|---|---|---|
| ローカル | online(devプロジェクト) | ADC(ユーザーアカウント) |
| PR CI(予定: [#25](https://github.com/tksrmz/household_accouts_firebase/issues/25)) | Firestoreエミュレータ | 不要 |
| デプロイAction(予定: [#26](https://github.com/tksrmz/household_accouts_firebase/issues/26)) | online | WIF(キーレス) |
