# 見送っている依存パッケージの更新

このファイルは、DependabotのPRのうち「今は入れない更新」と、その理由・解除できる条件の一覧である。`.github/workflows/dependabot-triage.yml` がDependabotのPRを判定するときにClaudeが読む(ライブドキュメント)。

- 見送りに当たり、解除の条件を満たしていないPRは、ワークフローがこのファイルの該当する節へのリンクを付けてクローズする
- 解除の条件は、見送りに当たるPRが無くても、毎日のscheduleと手動の実行で確かめる。満たしていれば、ワークフローがその節を消すPRを作る。消すPRがマージされるまでは、この一覧が実態より古い
- 判定したPRには、更新する依存の更新前後と、当たる見送りについて確かめたこと(見た値と、条件のどこを満たしている・いないか)をコメントで残す。見送りごとの確認は、PRが無くても実行のサマリーに残る
- **見送りを足すのは人だけ**。CIが失敗したのに見送りに当たらないPRは、ワークフローが原因の見立てをコメントして残すので、人が見て、入れない更新ならここに節を足す
- `.github/dependabot.yml` の `ignore` は使わない。`ignore` に書くとPRが作られなくなり、解除の条件を誰も確かめなくなるため

## 書き方

1つの見送りにつき1つの節(`##` 見出し)を書く。見出しは `<パッケージ名> <見送るバージョンの範囲>`(この見出しがアンカーになり、クローズのコメントからリンクされる)。

- **エコシステム**: `npm`(ディレクトリも書く)/ `pub` / `github-actions`
- **見送る範囲**: semverの範囲。この範囲に入るバージョンへの更新だけが見送りに当たる
- **理由**: 入れられない理由。確かめた日と、確かめた事実(peerDependenciesの範囲など)を書く
- **解除の条件**: 解除できたことを確かめる方法。`npm view` やpub.devのAPIのように、コマンドで確かめられる形で書く。ワークフローのClaudeは `npm view`・`npx semver`・`https://pub.dev/api/packages/` だけを使える。「上げようとするバージョン」は、そのパッケージを上げるPRがあればそのバージョン、無ければ見送る範囲に入る最新版として確かめられる
- **記録日**

## typescript >=7.0.0

- **エコシステム**: npm(`firebase/functions`)
- **見送る範囲**: `>=7.0.0`
- **理由**: `@typescript-eslint/eslint-plugin` と `@typescript-eslint/parser` の8系が、peerDependenciesで `typescript: ">=4.8.4 <6.1.0"` を求めていて、TypeScript 7では `npm ci` が依存の解決に失敗する(ERESOLVE)。2026-11-25に、最新の8.74.0とcanaryの8.74.1-alpha.1で確かめた。#5をこの理由でクローズした
- **解除の条件**: `npm view @typescript-eslint/eslint-plugin@latest peerDependencies.typescript` と `npm view @typescript-eslint/parser@latest peerDependencies.typescript` の両方の範囲に、上げようとするTypeScriptのバージョンが入る(`npx --yes semver@7.7.2 <バージョン> --range '<範囲>'`)。typescript-eslintの更新はTypeScriptの更新とは別のPRで来るので、先にそれが入っている必要がある
- **記録日**: 2026-11-25

## firebase-admin >=14.0.0

- **エコシステム**: npm(`firebase/functions`)
- **見送る範囲**: `>=14.0.0`
- **理由**: `firebase-functions-test` の3.5.0(2026-11-25時点の最新)が、peerDependenciesで `firebase-admin: "^8.0.0 || ^9.0.0 || ^10.0.0 || ^11.0.0 || ^12.0.0 || ^13.0.0"` を求めていて、firebase-admin 14では `npm ci` が依存の解決に失敗する(ERESOLVE)。`firebase-functions` の7.4.0は `^14.0.0` に対応済み。#63をこの理由でクローズした
- **解除の条件**: `npm view firebase-functions-test@latest peerDependencies.firebase-admin` の範囲に、上げようとするfirebase-adminのバージョンが入る(`npx --yes semver@7.7.2 <バージョン> --range '<範囲>'`)。firebase-functions-testの更新は別のPRで来るので、先にそれが入っている必要がある。v14はレガシーの名前空間APIとInstance ID APIを削除しているので、解除してマージした後に `firebase/functions/src/` がそれらを使っていないことを人が確かめる
- **記録日**: 2026-11-25
