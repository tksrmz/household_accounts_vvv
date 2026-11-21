# household_lints

アプリのRepositoryの規約を、Dartのanalyzer plugin(`analysis_server_plugin`)で機械的に検証するパッケージ。規約そのものと、その規約を選んだ理由は [docs/architecture.md の「Result と Result.guard」](../../docs/architecture.md#71-result-と-resultguard) と [docs/style_guide.md の「データ層」](../../docs/style_guide.md#44-データ層libdatarepositories) にある。

アプリとは独立したpub packageで、アプリの `pubspec.yaml` には依存を足さない(読み込み方は「有効化の方法」)。

## ルール

ルールは3つある。どれも重大度をERRORにしているので、違反があると `dart analyze` の終了コードが0以外になる(CIで確実に止めるため)。

| ルール | 検証すること |
|---|---|
| `repository_must_use_result_guard` | `Future<Result<T>>` を返す公開メソッドは、本体を `Result.guard(...)` を直接返す形(`=> Result.guard(...)` か、`return Result.guard(...);` だけのブロック)にする。`async` を付けたもの・`await` したもの・try/catchを手書きしたものは違反。本体の無い(抽象の)メソッドは対象外 |
| `repository_no_bare_future` | 公開メソッドは、素の `Future`(型引数が `Result` でないもの・nullableなもの)や `FutureOr` を返さない。返り値の型を省略した `async` のメソッドや `void ... async` も違反。抽象のメソッドも対象。同期の素の `T`(`getCurrentUser()` など)と `Stream` は対象外 |
| `repository_no_public_properties` | 公開のgetter・setter・フィールドを持たない(static・final・constを問わない)。公開するAPIはメソッドだけにする |

対象は、次の2つを両方満たす宣言である(`lib/src/rules/target_path.dart`)。

- ファイルが `lib/data/repositories/` 配下にある(パスを区切り文字で分けて判定するので、WindowsとCIのどちらでも同じ結果になる)
- 宣言を直接囲むクラスまたはmixinの名前が `Repository` で終わる。抽象(`abstract interface class XxxRepository`)も実装(`FirestoreXxxRepository`)も対象になる。同じフォルダのDTOやヘルパーは対象にならない

`Result` 型は、名前が `Result` で、宣言しているライブラリのパスが `utils/result.dart` で終わるものだけを認める(`lib/src/rules/result_type.dart`)。

## 有効化の方法

リポジトリ直下の `analysis_options.yaml` の、トップレベルの `plugins` で読み込む。プラグインが定義するlintルールは既定で無効なので(`main.dart` で `registerLintRule` を使っているため)、`diagnostics` でルールごとに有効にする。

```yaml
plugins:
  household_lints:
    path: packages/household_lints
    diagnostics:
      repository_must_use_result_guard: true
      repository_no_bare_future: true
      repository_no_public_properties: true
```

`plugins` を書き換えたときやプラグインのコードを変えたときは、Dart Analysis Serverを再起動しないとIDEに反映されない。

## 検証の手順

ルールを変えたときは、次の3つを順に確かめる。CI(`.github/workflows/pr-ci.yml`)も同じ順で、ルールのテストを `dart analyze` より先に実行する。ルールが壊れていると、`dart analyze` は「違反が0件」と「ルールが動いていない」を見分けられないため。

コマンドを打つ前に、mise のshimsをPATHへ前置する(リポジトリ直下の `CLAUDE.md` の「環境の前提(mise)」)。

### 1. パッケージでルールのテストを実行する

```bash
cd packages/household_lints
dart pub get
dart test
```

テストは `test/rules/` にあり、`analyzer_testing` の `AnalysisRuleTest` で書いている。

### 2. ルートで `dart analyze` を実行する

先にアプリの依存と生成コードをそろえ、違反の無い状態で終了コードが0になることを確かめる。生成コード(`*.freezed.dart`)が無いと、それだけでエラーになり、次の手順3で違反を検知できたかどうかを見分けられない。

```bash
flutter pub get
dart run build_runner build
dart analyze
```

`flutter analyze` ではなく `dart analyze` を使う。`flutter analyze` を1回だけ実行する形(analyze_once)は、解析の進捗が完了した時点でサーバーを終わらせるので、遅れて届くプラグインの診断を取りこぼすことがある。

### 3. 実ファイルへ違反を一時的に入れ、検知されることを確かめる

`lib/data/repositories/` 配下の実ファイルへ、各ルールの違反を一時的に入れる。たとえば `lib/data/repositories/property/firestore_property_repository.dart` の `FirestorePropertyRepository` で、次のように変える。

```dart
// repository_must_use_result_guard: 既存のdeleteにasyncを付け、
// Result.guardを直接返さない形にする
@override
Future<Result<void>> delete(PropertyId id) async =>
    Result.guard(() => _collection.doc(id.value).delete());

// repository_no_bare_future: 素のFutureを返すメソッドを足す
Future<void> touch() async {}

// repository_no_public_properties: 公開のgetterを足す
int get count => 0;
```

```bash
dart analyze
echo $?
```

3つの違反がそれぞれのルール名(`- repository_must_use_result_guard` など)で `error` として報告され、終了コードが0以外になることを確かめる(PowerShellでは `$LASTEXITCODE` で見る)。確かめたら変更を元に戻し、`git status` で差分が残っていないことを確かめる。

```bash
git checkout -- lib/data/repositories/property/firestore_property_repository.dart
git status
```

## ルールの追加手順

1. `lib/src/rules/<ルール名>.dart` に、`AnalysisRule` を継承したルールを書く。`LintCode` は `static const` で持ち、CIで止めたいなら `severity: DiagnosticSeverity.ERROR` にする。対象の絞り込みは `isRepositoryApiDeclaration`(`target_path.dart`)を使う
2. `lib/main.dart` の `register` で `registry.registerLintRule(...)` を呼んで登録する
3. `test/rules/<ルール名>_test.dart` に、違反を検知するケースと、検知しないケース(対象外のフォルダ・対象外のクラス名を含む)を書く。`Result` のスタブは、既存のテストと同じく `lib/utils/result.dart` に置く
4. リポジトリ直下の `analysis_options.yaml` の `diagnostics` に `<ルール名>: true` を足す
5. 「検証の手順」の1〜3を行う
6. 規約を `docs/architecture.md`・`docs/style_guide.md` にも書く

## 変更履歴

- 2026-11-21: 初版作成(ルールの一覧、有効化の方法、検証の手順、ルールの追加手順)
