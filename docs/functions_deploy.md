# Cloud Functionsのデプロイ

Cloud Functions(`firebase/functions/`)の本番へのデプロイは、GitHub Actionsのワークフロー `.github/workflows/functions-deploy.yml` が行う。手でデプロイすると、ソースの宣言(`engines.node`)と本番のランタイムがずれたまま気づかないことがあるため(実際に本番が廃止済みのnodejs20のまま残っていた。[ADR-001](./adr/001-firebase-functions-node22.md))。

## 流れ

1. `firebase/functions/**`・`firebase/firebase.json`・ワークフロー自体を変えたPRがmasterにマージされると、ワークフローが動く(Actionsの画面から手動で動かすこともできる)
2. GitHubの `production-functions` エンバイロメントの承認待ちになる。承認するとデプロイが始まる
3. Workload Identity Federationでデプロイ用のサービスアカウントになりすまし、`firebase deploy --only functions --project production` を実行する。firebase-toolsは `mise.toml` の `firebase` と同じバージョンをnpmから取り、miseのNode.jsで動かす
4. デプロイの後に `firebase functions:list --json` で本番を読み、すべての関数が1st gen(`gcfv1`)で、ランタイムが `engines.node` に対応する値(`nodejs22`)であることを確かめる(`docs/adr/checks/001-firebase-functions-node22.production.mjs`)。違えばワークフローが失敗する

## 前提の設定

一度だけ行う。**ワークフローをmasterへマージする前に、GitHubのエンバイロメントを先に作る**。ワークフローが参照したエンバイロメントが無いと、保護ルールの無いエンバイロメントが自動で作られ、承認なしでデプロイが走りうるため(その場合も変数が無いので最初のステップで止まるが、それに頼らない)。

### 1. GitHubの `production-functions` エンバイロメント

リポジトリの Settings → Environments → New environment で `production-functions` を作る。名前に対象(functions)を入れるのは、アプリやFirestore Rulesの本番デプロイを足すときに、対象ごとに承認・ブランチ制限・変数を分けるため。

- **Required reviewers**: 自分を追加する。ほかに承認者がいないので「Prevent self-review」はオフにする
- **Deployment branches and tags**: 「Selected branches and tags」にし、`master` だけを追加する
- **Environment variables**: 次の2つを足す(値は下の2.で決まる)
  - `GCP_WORKLOAD_IDENTITY_PROVIDER`: `projects/<プロジェクト番号>/locations/global/workloadIdentityPools/github/providers/github-actions`
  - `GCP_DEPLOY_SERVICE_ACCOUNT`: `github-functions-deploy@household-accounts-1129d.iam.gserviceaccount.com`

秘密の値は無いので、secretsではなくvariablesに置く。

### 2. Google Cloud(本番プロジェクト `household-accounts-1129d`)

Google Cloud Consoleで行う。プロジェクト番号はConsoleのダッシュボードで確かめる。

1. **デプロイ用のサービスアカウント**を作る: IAMと管理 → サービスアカウント → 作成。ID は `github-functions-deploy`
2. **権限を付ける**(2026-11時点の公式ドキュメントから組み立てたもので、firebase-toolsに必要な最小限の一覧は公式に無い。最初の実行で権限不足のエラーが出たら、エラーに書かれた権限を持つロールを足す)
   - プロジェクトに対して: Cloud Functions 開発者(`roles/cloudfunctions.developer`)
   - プロジェクトに対して: Firebase 閲覧者(`roles/firebase.viewer`)。firebase-toolsはデプロイの最初にFirebaseのプロジェクト設定(`adminSdkConfig`)を読むため、これが無いと403で止まる(2026-11-25の最初の実行で確認)
   - 関数の実行サービスアカウント `household-accounts-1129d@appspot.gserviceaccount.com` に対して: サービス アカウント ユーザー(`roles/iam.serviceAccountUser`)
   - Cloud Buildのサービスアカウントには付けない。この権限が要るのはビルド用のアカウントを指定してデプロイするときで、このワークフローは指定しないため。本番では `gcloud builds get-default-service-account` が `<プロジェクト番号>@cloudbuild.gserviceaccount.com` を返すが、そのアカウントはプロジェクトに存在しない(2026-11-25に確認)。最初の実行でビルドのアカウントに対する `iam.serviceAccounts.actAs` の不足が出たら、エラーに書かれたアカウントに対してサービス アカウント ユーザーを付ける
3. **Workload Identity プール**を作る: IAMと管理 → Workload Identity 連携 → プールを作成
   - プールID: `github`
   - プロバイダ: OpenID Connect(OIDC)、プロバイダID `github-actions`、発行元(URL) `https://token.actions.githubusercontent.com`
   - 属性のマッピング:
     - `google.subject` = `assertion.sub`
     - `attribute.repository_id` = `assertion.repository_id`
   - 属性条件(このリポジトリの、masterからの、`production-functions` エンバイロメントのジョブだけを通す。リポジトリには課題やPRのイベントで動くワークフローもあるので、リポジトリだけで絞らない。リポジトリは名前ではなく、使い回されない数値IDで指定する):

     ```text
     assertion.repository_id == '1337093130' && assertion.ref == 'refs/heads/master' && assertion.environment == 'production-functions'
     ```

4. **なりすましを許可する**: 1.のサービスアカウント → 権限 → アクセスを許可 で、次のプリンシパルに Workload Identity ユーザー(`roles/iam.workloadIdentityUser`)を付ける

   ```text
   principalSet://iam.googleapis.com/projects/<プロジェクト番号>/locations/global/workloadIdentityPools/github/attribute.repository_id/1337093130
   ```

5. IAM Service Account Credentials API(`iamcredentials.googleapis.com`)が有効でなければ有効にする(サービスアカウントのなりすましに使う)

### 確かめたこと・確かめていないこと

2026-11-25に、この設定でCIからの最初のデプロイと、ADR-001の本番の検査が成功した。これで次のことを確かめた。

- `environment:` を付けたジョブのOIDCトークンに `ref` クレームが入り、上の属性条件のままで認証が通ること
- 上の2.の権限で足りること(最初の実行はFirebase 閲覧者が無く、`adminSdkConfig` の読み取りの403で失敗した)

次は確かめていない(エンバイロメントを先に作ったため、起きる状況にならなかった)。外れていても変数が無いので最初のステップで止まり、承認なしでデプロイが通る側には倒れない。

- ワークフローが参照したエンバイロメントが無いとき、GitHubが保護ルールの無いエンバイロメントを自動で作ること

## 手でデプロイするとき

CIが使えないときだけ、手元から行う。Windowsではmiseの `firebase`(単体バイナリ)を使わない(CLAUDE.md参照)。

```bash
cd firebase
npx --yes firebase-tools@<mise.tomlのfirebaseのバージョン> deploy --only functions --project production
npx --yes firebase-tools@<mise.tomlのfirebaseのバージョン> functions:list --project production --json \
  | node ../docs/adr/checks/001-firebase-functions-node22.production.mjs
```

## 変更履歴

- 2026-11-23: 初版。デプロイをGitHub Actionsへ移した
- 2026-11-25: Cloud Buildのサービスアカウントへの権限付与を外した(本番に既定のアカウントが存在しない)
- 2026-11-25: 権限にFirebase 閲覧者を足した(CIからの最初のデプロイが `adminSdkConfig` の読み取りの403で失敗した)
- 2026-11-25: CIからの最初のデプロイが成功したことに合わせて、「確かめていないこと」を書き直した
