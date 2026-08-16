# household_accounts

App of  household accounts

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Golden tests

Golden画像は、Linux CIで生成してGit管理するcanonical Goldenと、各開発環境で
生成してGit管理しないlocal Goldenに分けています。

テストコードはcanonical Goldenのパスを指定します。ローカルでテストを実行すると、
Golden comparatorが自動的に次のOS別パスへ切り替えます。

```text
test/.../golden/example.png                  # canonical（Git管理）
test/.../golden/.local/windows/example.png   # local（gitignore）
test/.../golden/.local/linux/example.png     # local（gitignore）
```

### ローカル環境の初期構築

local Goldenは自動生成されません。初回構築時に次のコマンドで生成してください。

```bash
flutter test --tags golden --update-goldens
```

通常の比較は次のコマンドで実行します。

```bash
flutter test --tags golden
```

画面を意図的に変更した場合も、内容を確認してから`--update-goldens`でlocal Goldenを
更新してください。ブランチ切り替えなどで不整合が生じた場合は、`golden/.local`または
`goldens/.local`ディレクトリを削除して再生成できます。

### canonical Goldenの更新

canonical Goldenはローカルから更新しません。Pull RequestのGolden CIがLinux上で
canonical候補を再生成し、更新要否をGit差分で判定します。更新が必要な場合は、Actionsの
`Update canonical goldens` workflowを実行し、対象Pull Request番号を入力してください。
workflowが生成したcanonical GoldenだけをPull Requestブランチへコミットします。

ローカルでの誤コミットを早期に検出するため、初回構築時にリポジトリ同梱のpre-commit
hookを有効にしてください。

```bash
git config core.hooksPath .githooks
```

このhookはcanonical Goldenのコミットを拒否します。hookを回避した変更も、Pull Request
CIがLinuxで再生成した内容と比較して検出します。
