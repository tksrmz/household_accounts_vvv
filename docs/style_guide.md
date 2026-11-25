# 開発スタイルガイド

このドキュメントは、本プロジェクトの設計・開発・テスト・ドキュメント運用のスタイルを定義する。構造の全体像と、その構造を選んだ理由は [architecture.md](./architecture.md) にある。

---

## 1. ドキュメント管理ポリシー

### スナップショット型(履歴管理)

| ドキュメント | 内容 |
|--------------|------|
| **PRD(Product Requirements Document) + 仕様書** | 機能の目的、背景、ビジネス要件を記述する。新機能の詳細仕様、ユースケース、エッジケースなど。 |

保存先: `/docs/features/YYYYMM_<feature-name>.md`

---

### ADR(Architecture Decision Record)

コードや設定を見ただけでは理由が分からない決定(ランタイムのバージョンを上げない理由など)を、1決定1ファイルで残す。

- 雛形は `/docs/adr/template.md`。タイトル・ステータス・コンテキスト・決定・影響・コンプライアンスの6項目を書く
- 保存先: `/docs/adr/NNN-<内容を表す英語のkebab-case>.md`(NNNは001からの3桁の連番)
- 承認した決定の内容は書き換えない。決定を変えるときは新しいADRを起こし、古いADRのステータスを破棄にする。破棄する側と破棄される側の両方のステータスに相手の番号を書く
- コンプライアンスのうち機械で確かめられるものは検査にする。リポジトリのファイルで確かめられるものは `/docs/adr/checks/NNN-*.test.mjs`(Node.js標準の `node:test`。依存パッケージを使わない)に書き、`adr-compliance.yml` が全PRで走らせる。本番の状態など、それ以外のものは、確かめる仕組み(ワークフローなど)をコンプライアンスの項目に書く
- ADRを破棄するときは、そのADRの検査も新しいADRに合わせて書き換えるか消す

---

### ライブドキュメント型(常に最新を保つ)

| ドキュメント | 内容 | 保存先 |
|--------------|------|------|
| **アーキテクチャ構成図** | 全体構成、コンポーネントの関係性。 | `/docs/architecture.md` |
| **各コンポーネント仕様** | 責務、制約、インタフェース。Test as a specificationやプロダクションコードのコメントで表現。 | `/test/data`, `/test/domain`(単体テスト) |
| **DB設計図** | スキーマ、リレーション、マイグレーション指針。 | `/docs/firestore_schema.md` |
| **UI/UXフロー** | 状態遷移、画面遷移、ユーザー操作の仕様。Test as a specificationやプロダクションコードのコメントで表現。 | `/test/ui/`(ViewModel・Widget・goldenテスト)、`/integration_test/`(Integrationテスト) |

#### 各コンポーネント仕様とUI/UXフローについて補足

テストでは「何をしているか」(What)、プロダクションコードのコメントには「なぜそうしているか」(Why)を記載する。

---

## 2. ディレクトリ構成

`lib/` の中身は [architecture.md の「フォルダ構成」](./architecture.md#2-フォルダ構成) を参照。リポジトリ全体は次のとおり。

```text
household_accounts_claude/
├── lib/                    # アプリ本体(config / routing / domain / data / ui / utils)
├── test/                   # lib/ と同じ構成で置く単体・Widget・goldenテスト
│   └── test-util/          # 手書きFake(fake_*_repository.dart)、goldenのヘルパー
├── integration_test/       # ユーザーストーリー単位のIntegrationテスト(*_feature_test.dart)
│   ├── util/               # UI操作・データ投入・Firestoreの実データ確認のヘルパー
│   └── saved-data/         # エミュレータへimportするシードデータ
├── packages/
│   └── household_lints/    # Repository規約を検証するanalyzer plugin
├── firebase/               # Firebaseバックエンド(Rules・Cloud Functions・Hosting)
└── docs/
    ├── features/           # スナップショットドキュメント
    ├── adr/                # ADR(template.mdが雛形)
    │   └── checks/         # ADRのコンプライアンス検査
    ├── architecture.md
    ├── style_guide.md      # このドキュメント
    ├── firestore_schema.md
    ├── firestore_constraints.md
    ├── functions_deploy.md # Cloud FunctionsのCIデプロイと前提の設定
    └── dependency_holds.md # 見送っている依存の更新と、その理由・解除の条件(dependabot-triage.ymlが読む)
```

---

## 3. 命名規則

- **フォルダ名/ファイル名**: `snake_case`(例: `lib/ui/record_entry/record_entry_screen.dart`)
  - ファイル名はリポジトリ内で一意になるようにする(`page.dart` のような汎用名にしない)。エディタやエージェントで検索しやすくするため
- **クラス名**: `PascalCase`。役割をSuffixとしてつける
  - UI: `XxxScreen`(`xxx_screen.dart`)/ `XxxScreenHost`(`xxx_screen_host.dart`)/ `XxxViewModel`(`xxx_view_model.dart`)
  - データ層: 抽象 `XxxRepository`(`xxx_repository.dart`)/ 実装 `FirestoreXxxRepository`(`firestore_xxx_repository.dart`)/ DTO `XxxDto`(`xxx_dto.dart`)
  - テスト: `FakeXxxRepository`(`test/test-util/fake_xxx_repository.dart`)
- **関数・変数名**: `camelCase`(例: `updateUserName()`)
  - 定数も `camelCase` で定義する
- **テスト名**
  - Integrationテスト以外
    - `<前提>のとき、<期待値>であること` という形式で命名する
      - 例: `0文字のユーザー名はバリデーションエラーで保存に失敗すること`
  - Integrationテスト
    - UserStoryの形式で命名する
    - `<ペルソナ>は<機能>を使えるので、<メリット>を享受できる`
      - 例: `ユーザーは自分の家計簿でカテゴリを管理できるので、収支をカテゴリ別に整理できる`

---

## 4. 設計ルール

### 4.1 全体

- 層はUI層とデータ層の2つで、両方からドメインモデルを使う。UseCase層は置かない。画面をまたぐロジックはドメインモデルの純粋関数にする(例: `BudgetSummary.from`)
- 依存の向きは UI層 → データ層 の一方向にする
- コードコメントには「なぜそうしているか」を書く
- **コードコメントに設計ドキュメントの決定番号(D1〜D10、O1〜O6など)を書かない**。番号はドキュメントの改訂で通じなくなるため、決定の**内容**を書く

### 4.2 ドメインモデル(`lib/domain/models/`)

- 不変の型だけを置く。クラスはfreezedで生成する。値を束ねるだけの小さな組は、名前付きrecordの `typedef` にする(`BalanceEffect`・`CategorySpending`)
- **1つのファイルに1つの型**を置く。IDは対応するモデルの隣に置き(`property.dart` と `property_id.dart`)、`ids.dart` のような寄せ集めのファイルは作らない。モデルを足したり消したりするときに、触る場所がそのモデルの周りで済むようにするため
- **IDはfreezedの値型**にする。extension typeは使わない(実行時に型が消えて素の `String` になり、実行時の型検査を捨てることになるため)
- 値型にするのは、IDと検証を持つ値だけにする。検証のない値(資産の残高など)は値型で包まない
  - 例外は記録の日付 `RecordDate`。値型だがコンストラクタで検証しない(`const factory` で書く)。本番やintegrationのシードには未来日付の記録がありうるので、読み取りで拒否すると画面が読み込めなくなるため。未来日付は記録入力の入力境界(DatePickerの `lastDate` と保存時の確認)で拒否する(詳細は [architecture.md の「ドメインモデル」](./architecture.md#4-ドメインモデル))
- **検証付きの値型は、コンストラクタで検証して例外を投げる**。`@Assert` はデバッグビルドでしか効かないので、値型の検証には使わない
  - ユーザーが入力しうる値(`Amount`・`UserName` など)は `FormatException`。UI層が受けて検証エラーの状態にする
  - システムの内部で決まる値(IDなど)は `ArgumentError`。捕まえずにfail fastさせる
  - 判定は `static bool isValid(...)` として公開し、コンストラクタと同じ条件をUI層のライブ検証から使う(ルールの記述を1か所にする)
  - 値型は自前のコンストラクタとfinalフィールドを持つfreezedのクラスで書く。フィールドに `@override` は付けない(freezed 4の生成mixinがgetterを宣言しないため)
- **UIの文言をドメインに置かない**。例外のメッセージは原因調査のための事実だけを書き、画面の文言(「削除済み」「〜してください」など)はWidget層が持つ

### 4.3 UI層(`lib/ui/`)

- 1機能1フォルダにし、`<feature>_screen.dart`・`<feature>_screen_host.dart`・`<feature>_view_model.dart`・`widgets/` を置く。同じ機能の2画面目(エディタ・日次明細など)も同じフォルダに置く
- 複数の画面で使うものは `lib/ui/core/` に置く(`SelectedNotebook`・`Formatter`・テーマ・共通Widget)
- **ViewModelはRepositoryのインターフェースを注入で受け取る**。`Stream<T> Function(...)` のような関数で渡さない。現在時刻は `DateTime Function() now` で差し替えられるようにする(テストで日付を固定するため)
- ViewModelはProviderに登録しない。Hostが `initState` で生成し、`dispose` で破棄する。ノートに依存する画面のHostには、ルート側で `ValueKey(notebook)` を付ける
- Screenはコンストラクタで受け取ったViewModelを `ListenableBuilder` で購読する。Screenにロジックを置かない
- ユーザー操作から始まる完了する非同期処理は `Command0` / `Command1` にする。流れ続けるwatchの購読はCommandに載せず、ViewModelのフィールドで状態を表す
- watchの購読には必ず `onError` を付け、`Exception` はエラー状態に、`Error` は `Error.throwWithStackTrace` で投げ直す。エラー状態にするときは `developer.log` で原因を残す
- **入力の検証はUI層の関心事として、ViewModelの状態で表す**。保存のCommandは検証済みの型だけを受け取る(例: `Command1<void, UserName>`)。Commandの失敗はデータ層から来た失敗だけを表す
- 入力は変わるたびに検証し(ライブ検証)、不正なら保存ボタンを押せなくする。開いた直後の空欄はまだエラー表示にしない
- **入力の判定は、入力を引数に取る純粋関数にする**(例: `static bool _isBalanceValid(String balanceInput)`)。ViewModelの状態を読むgetterにしない。どの入力に対する判定かが呼び出し側で明らかになるため
- **入力フォーマッタで文字を取り除いて値を書き換えない**。「100,000」が「100」に、「1234.50」が「123450」になるように、不正な入力が別の有効な値に化けてしまう。入力はそのまま検証にかけ、不正なら保存させない
- スナックバーのような一度きりの通知は、ScreenがCommandにリスナーを付けて出し、出したら `clearResult()` する(buildの中で出さない)
- 削除の確認ダイアログはWidget層に置く。ViewModelは確認済みの操作だけを受け取る
- **エディタの編集モードでは、初期値から変わったフィールドだけを `update` に渡す**(資産・カテゴリのエディタ)。変わっていないフィールドを書き戻すと、エディタを開いている間に入った変更(記録入力による残高の増減、ペア相手の編集)を開いた時点の値で上書きしてしまう。何も変わっていなければRepositoryを呼ばず、成功として画面を閉じる(編集を終えるという意図は満たされているため)
- 表示期間の切り替え・複数の購読・「今日」の扱いは [architecture.md の「購読の管理」](./architecture.md#34-購読の管理) に従う

### 4.4 データ層(`lib/data/repositories/`)

- 機能ごとのフォルダに、抽象(`abstract interface class`)・Firestore実装・DTOを同居させる。Service層は置かない
- 抽象のdocコメントには呼び出し側が頼ってよい契約だけを書き、実装の詳細は書かない
- 読み取りは素の `Stream<T>`、失敗しうる単発の操作は `Future<Result<T>>` を返す
- **`Future<Result<T>>` を返す公開メソッドは、本体を `Result.guard(...)` の1行にする**。try/catchを手書きしない。この規約と「素の `Future` を返さない」「公開のgetter・setter・フィールドを持たない」は `packages/household_lints` が検証する(`dart analyze` で確認する)
- 呼び出し側の不具合(更新するフィールドを1つも渡さないなど)は `ArgumentError` を投げる。`Result.guard` は `Error` を捕まえないので、そのまま伝わる
- 記録・カテゴリ・資産のRepositoryでは、読み取りはDTOの `fromSnapshot` → `toDomain()` で変換し、フィールドの欠損・型の不正は `FormatException` にする。書き込みのJSONはDTOファイル内のトップレベル関数で組み立てる。`withConverter` は使わない
  - `FirestoreProfileRepository` はDTOを持たず、ドキュメントのフィールドを直接読み書きする。失敗の形がDTOと違う(ユーザー名が無いときは素の `Exception`)。詳細は [architecture.md の「DTOと書き込みJSON」](./architecture.md#53-dtoと書き込みjson)
- 更新は渡されたフィールドだけを書く
- 個人ノート・共有ノートのパスは `notebook_paths.dart` の `notebookPath()` で組み立て、Repositoryごとに組み立てない
- 読み取りを伴わない複数書き込みは `WriteBatch`、読み取りを伴うものは `runTransaction` にする
- 資産・カテゴリの削除に参照チェック(削除ガード)は入れない(理由は architecture.md の「資産・カテゴリの削除」)
- ユーザーが自分で直せないデータの不正は、読み取り側で吸収せず、書き込み側(アプリの検証とFirestore Rules)で防ぐ

### 4.5 DI(`lib/config/dependencies.dart`)

- DIは `provider` だけを使う。Repositoryと複数画面にまたがる状態だけを `appProviders()` に登録する
- ノートに依存するRepositoryは `ProxyProvider2<SelectedNotebook, UserAuth, XxxRepository>` で作り直す

### 4.6 ルーティング(`lib/routing/`)

- パスは `routes.dart` の定数を使う
- タブの画面はシェル内のブランチ、ボトムナビを覆う画面はシェル外のルートレベルに置き、`context.push` で開く
- 編集対象は `extra` で渡す。想定外の型が来たら `ArgumentError` でfail fastさせる

---

## 5. テスト方針

| 種別 | 目的・内容 | 必須度 | 保存先 | 記述方針 |
|------|------------|--------|--------|----------|
| **ユニットテスト** | ドメインモデル・DTO・書き込みJSON・ViewModelの振る舞い | ◎ | `test/domain/` `test/data/` `test/utils/` `test/ui/` | Test as a specificationで「何をしているか」を書く |
| **Widgetテスト** | ユーザー操作とViewModelへの伝わり方、Hostの作り直し | ◎ | `test/ui/` | ユーザー操作・UI仕様を書く |
| **goldenテスト** | 画面の見た目 | ◎ | `test/ui/**/golden/` | 状態ごとに3幅で撮る |
| **Integrationテスト** | UIからFirestoreまでの結合(画面単位) | ◯ | `integration_test/` | ユーザーストーリー単位。画面ごとに少なくとも1件 |

### テストの書き方

- **Repositoryは手書きのFakeに差し替える**(`test/test-util/fake_*_repository.dart`)。Fakeは抽象を実装し、watchは `StreamController` で任意の値・エラーを流せるようにし、書き込みは結果を差し替えられるようにして呼び出し引数を記録する。モック生成ライブラリは使わない
- ViewModelのテストは `testWidgets` ではなく `test` で書き、Streamのイベントは `pumpEventQueue()` で待つ(ViewModelはWidgetツリーを必要とせず、`testWidgets` の中で `StreamController.close()` などをawaitするとハングするため)
- **ViewModelのテストでCommandの内部状態(`running`・`error`・`completed`)を網羅しない**。それは `test/utils/command_test.dart` の責務。ViewModelのテストは、画面の振る舞いを説明するのに必要な範囲だけを確かめる
- **前提が同じで、1つの振る舞いを構成する期待値は、1つのテストにまとめる**。「1テスト1アサーション」を機械的に当てはめて、同じ前提のテストを並べない
- Firestore実装のRepositoryそのものには単体テストを書かない。パス解決・DTO・書き込みJSON・Streamの結合をそれぞれ単体テストし、Firestoreへの購読・書き込みの実効性はintegrationテストで確かめる

### goldenテスト

- `test/test-util/golden_helper.dart` の `testGoldens` で、3つの画面幅(320 / 375 / 414)を撮る。画像はテストファイルの隣の `golden/<名前>_<幅>.png` になり、`golden` タグが付く
- ダイアログのようなオーバーレイは3幅ヘルパーで画面に重ねて撮れないので、ダイアログ単体で撮る
- 正本の画像(`test/**/golden{,s}/**/*.png`)はCIが管理する。ローカルでのコミットは追加・変更・削除のいずれもpre-commitフックが拒否する。更新・削除はPR作成後に `update-canonical-goldens.yml` をworkflow dispatchする
- ローカルではgitignoreされた `.local/` 配下の基準画像と比べる。基準が無いときは先に `flutter test --tags golden --update-goldens` で作る

### Integrationテスト

- Firebaseエミュレータとシードデータ(`integration_test/saved-data`)で動かす。実行手順の正は `integration_test/README.md`
- 画面表示に加えて、`integration_test/util/firestore_probe.dart` でFirestoreの実データ(フィールド・参照先・資産残高の増減)を確かめる
- **UI操作は `integration_test/util/` に集約する**(`ui_operations.dart`・`record_entry_operations.dart`・`property_operations.dart`・`category_operations.dart`)。同じ操作をテストファイルごとに書かない
- UIから入れられないデータ(未来日付の記録など)は、`record_seeding.dart`(Firestore REST API)で投入する
- 共有ノートのシナリオは、シード済みのペアユーザーでサインインし、共有ノートへ切り替えて行う

### テスト記述・管理に関するルール

- テストは「何をしているか(What)」を明確に記述する(Test as a specification)
- プロダクションコードのコメントには「なぜそうしているか(Why)」を記載する
- テストの追加・修正時は、関連するドキュメント(`docs/architecture.md`、`docs/firestore_schema.md` など)も必要に応じて更新する

---

## 6. 新規参画者向け情報

### Git / ブランチ戦略

- ブランチ命名: `dev/xxx`

### 開発環境

- flutter / dart / firebase / node のバージョンはリポジトリ直下の `mise.toml`(+ `mise.lock`)が唯一の正。手順は `CLAUDE.md` を参照
- 生成コード(`*.freezed.dart`)はコミットしない。`dart run build_runner build` で生成する

### 使用ライブラリ

`pubspec.yaml` の内容と一致させる。

#### プロダクション

| パッケージ | 用途 |
|---|---|
| provider | DI(Repositoryと共有状態の登録)。ViewModelは登録しない |
| go_router | ルーティング(認証redirect、`StatefulShellRoute` のタブ) |
| firebase_core / cloud_firestore / firebase_auth | Firebase |
| firebase_ui_auth | サインイン画面。importは `lib/ui/auth/` だけ |
| freezed_annotation | ドメインモデルの生成(freezedと組で使う) |
| intl | 金額・日付の表示形式(`Formatter.simpleCurrency`、記録入力の日付表示) |
| logging | ログレベルの定数(`developer.log` の `level` に使う) |

#### 開発

| パッケージ | 用途 |
|---|---|
| build_runner / freezed | freezedのコード生成 |
| flutter_test / test | テスト(`test` はDartだけのテストで使う) |
| integration_test | Integrationテスト |
| flutter_lints | 静的解析のルールセット |

`packages/household_lints` は独立したpub packageで、`analysis_options.yaml` の `plugins` から読み込む(アプリの `pubspec.yaml` には足さない)。

#### 使わないもの

| パッケージ | 理由 |
|---|---|
| get_it | DIは `provider` に一本化した |
| dartz / result_dart | エラー処理は自作の `Result<T>`(`lib/utils/result.dart`)で足りる |
| mockito / mocktail | テストは手書きのFakeで足りる(mockitoは `Result` を返すインターフェースのモックを生成できない) |
| equatable | 値の等価性はfreezedで足りる |
| uuid | ドキュメントIDはFirestoreの自動IDを使う |
| rxdart | Streamの結合は自作の `combineLatest3`(`lib/utils/combine_latest.dart`)で足りる |

---

## 7. コード例

いずれもリポジトリのコードからの抜粋(一部省略)。

### 推奨パターン

#### 検証付きの値型

```dart
// lib/domain/models/amount.dart
@freezed
class Amount with _$Amount {
  Amount(this.value) {
    if (!isValid(value)) {
      throw FormatException('金額は1以上である必要があります', value);
    }
  }

  static bool isValid(int value) {
    return value > 0;
  }

  final int value;
}
```

#### Repository実装の書き込み

```dart
// lib/data/repositories/property/firestore_property_repository.dart
@override
Future<Result<void>> update(
  PropertyId id, {
  PropertyName? name,
  int? balance,
}) => Result.guard(() => _update(id, name: name, balance: balance));

// ArgumentErrorはExceptionではないためResult.guardに捕捉されず、
// 呼び出し側の不具合としてそのまま伝播する(fail fast)。
Future<void> _update(PropertyId id, {PropertyName? name, int? balance}) {
  if (name == null && balance == null) {
    throw ArgumentError('nameとbalanceの少なくとも一方を指定してください');
  }
  return _collection
      .doc(id.value)
      .update(propertyUpdateJson(name: name, balance: balance));
}
```

#### ViewModel: watchの購読と検証済みの型を受けるCommand

```dart
// lib/ui/properties/property_editor_view_model.dart
late final Command1<void, ({PropertyName name, int balance})> save;

Future<void> submit() async {
  final PropertyName name;
  try {
    name = PropertyName(_nameInput);
  } on FormatException {
    _hasNameError = true;
    notifyListeners();
    return;
  }
  final balance = _parseBalance(_balanceInput);
  if (balance == null) {
    _hasBalanceError = true;
    notifyListeners();
    return;
  }
  await save.execute((name: name, balance: balance));
}
```

```dart
// lib/ui/properties/properties_view_model.dart
_propertiesSubscription = propertyRepository.watchAll().listen(
  _onProperties,
  onError: _onPropertiesError,
);

void _onPropertiesError(Object error, StackTrace stackTrace) {
  if (error is! Exception) {
    Error.throwWithStackTrace(error, stackTrace);
  }
  // ...developer.logで記録してエラー状態にする
  _loadError = error;
  notifyListeners();
}
```

`lib/utils/result.dart` の `Error<T>` は `dart:core` の `Error` と名前がぶつかる。`Error.throwWithStackTrace` を使うファイルでは `import '../../utils/result.dart' hide Error;` のように隠す。

#### ViewModelのテスト

```dart
// test/ui/properties/properties_view_model_test.dart
test('資産の一覧が届いたとき、読み込みが完了し届いた順に一覧が公開されること', () async {
  final target = _buildFixture();

  target.repository.propertiesController.add([_bank, _wallet]);
  await pumpEventQueue();

  expect(target.viewModel.isLoading, isFalse);
  expect(target.viewModel.properties, [_bank, _wallet]);
});
```

### アンチパターン

```dart
// ❌ Repositoryでtry/catchを手書きする(catch節の書き漏れが起きる。lintで検出される)
@override
Future<Result<void>> delete(PropertyId id) async {
  try {
    await _collection.doc(id.value).delete();
    return const Result.ok(null);
  } on FirebaseException catch (e) {
    return Result.error(e);
  }
}

// ❌ onErrorを付けずに購読する(エラーが未処理のまま流れる)
propertyRepository.watchAll().listen(_onProperties);

// ❌ 保存のCommandに未検証の文字列を渡す(検証漏れを型で防げない)
late final Command1<void, String> save;

// ❌ ViewModelがFirestoreを直接読む(テストでFakeに差し替えられない)
FirebaseFirestore.instance.collection('properties').snapshots().listen(...);

// ❌ 値型の検証をassertだけで行う(リリースビルドで検証が消える)
Amount(this.value) : assert(value > 0);
```

---

## 8. 参考リンク

- [Flutter公式ドキュメント](https://flutter.dev/)
- [Flutter App architecture](https://docs.flutter.dev/app-architecture)
- [Mermaid記法リファレンス](https://mermaid.js.org/)
- [Test as Specificationとは](https://martinfowler.com/bliki/SpecificationByExample.html)

## 変更履歴

- 2026-11-08: アーキテクチャ移行(移行計画PR1〜PR9)の完了に合わせて全面改訂
- 2026-11-21: cloud_firestore 6.9.0でAndroidの `runTransaction` 完了時の `MissingPluginException` が直った(firebase/flutterfire#18546)ため、integrationテストの限定フィルタの記述を削除した
- 2026-11-21: ADR(`docs/adr/`)の運用を追加した
- 2026-11-23: ADRのコンプライアンス検査(`docs/adr/checks/`)の運用を追加した
- 2026-11-25: 見送っている依存の更新の一覧(`docs/dependency_holds.md`)を追加した
