# 📘 開発スタイルガイド

このドキュメントは、本プロジェクトにおける設計・開発・テスト・ドキュメント運用のスタイルを定義します。

---

## 1. ドキュメント管理ポリシー

### 🔹 スナップショット型（履歴管理）

| ドキュメント | 内容 |
|--------------|------|
| **PRD（Product Requirements Document） + 仕様書** | 機能の目的、背景、ビジネス要件を記述する。新機能の詳細仕様、ユースケース、エッジケースなど。 |

保存先：`/docs/features/YYYYMM_<feature-name>.md`

---

### 🔹 ライブドキュメント型（常に最新を保つ）

| ドキュメント | 内容 |保存先|
|--------------|------|------|
| **アーキテクチャ構成図** | 全体構成、コンポーネントの関係性。 | `/docs/architecture.md` |
| **各コンポーネント仕様** | 責務、制約、インタフェース。Test as a specificationやプロダクションコードのコメントで表現。 | `/test/data`, `/test/domain`（単体テスト） |
| **DB設計図** | スキーマ、リレーション、マイグレーション指針。 | `/docs/firestore_schema.md` |
| **UI/UXフロー** | 状態遷移、画面遷移、ユーザー操作の仕様。Test as a specificationやプロダクションコードのコメントで表現。 | `/test/presentation/`（Widgetテスト）、`/integration_test/`（Integrationテスト） |

#### 各コンポーネント仕様とUI/UXフローについて補足

テストでは「何をしているか」（What）、プロダクションコードのコメントには「なぜそうしているか」（Why）を記載する。

---

## 2. ディレクトリ構成

```text
household_accounts/
├── docs/
│   ├── features/          # スナップショットドキュメント
│   ├── architecture.md    # アーキテクチャ関連
│   ├── style_guide.md     # 開発スタイルガイド（このドキュメント）
│   └── firebase_schema.md # DB設計図など
├── lib/
│   ├── data/              # データレイヤー
│   │   ├── models/        # 外部サービスから取得したデータ型
│   │   └── repository/    # Repository実装
│   ├── domain/            # ドメインレイヤー
│   │   ├── models/        # エンティティ
│   │   │   └── vo/        # 値オブジェクト
│   │   └── repository/    # リポジトリインターフェース
│   └── presentation/      # プレゼンテーションレイヤー
│       ├── pages/         # 機能ごとのページ
│       │   ├── feature/   # 機能名（例: home, settings）
│       │   │   ├── page.dart    # ページWidget
│       │   │   ├── view_model.dart  # ViewModel
│       │   │   └── widgets/     # 機能固有のWidget
│       │   └── commands/        # 一般的なCommand
│       └── widgets/             # 共通Widget
├── test/                  # テストコード
│   ├── data/              # データレイヤーのテスト
│   ├── domain/            # ドメインレイヤーのテスト
│   └── presentation/      # プレゼンテーションレイヤーのテスト
└── integration_test/      # Integrationテスト
```

---

## 3. 命名規則

- **フォルダ名/ファイル名**：`snake_case`（例：`parent_folder/child_folder/file_name.dart`）
- **クラス名**：`PascalCase`（例：`DarkModeToggleButton`）
  - 役割をSuffixとしてつける。（例：`DashboardViewModel`, `DashboardScreen`）
- **関数・変数名**：`camelCase`（例：`updateUserSetting()`）
  - 定数も`camelCase`で定義する。
- **テスト名**
  - Integrationテスト以外
    - `<前提>のとき、<期待値>であること`という形式で命名する。
      - 例：`0文字のユーザー名はバリデーションエラーで保存に失敗すること`
  - Integrationテスト
    - UserStoryの形式で命名する。
    - `<ペルソナ>は<機能>を使えるので、<メリット>を享受できる`
      - 例：`ユーザーは自分の家計簿でカテゴリを管理できるので、収支をカテゴリ別に整理できる`

---

## 4. 設計ルール

- 誓約によるプログラミングを推奨する。
- 単一責務の原則（SRP）を守る。
- 依存性逆転の原則（DIP）を適用する。
  - DIコンテナとして`Provider`を使用する。
  - Pageをビルドするタイミングで、View Modelも作成する。
    - View Modelが依存するRepositoryは、そのタイミングで`Provider`から取り出す。
  - Repositoryはアプリ全体のWidget構造のRootに近いところで`Provider`に登録される。
    - つまり、`main.dart`で`Provider`を定義する。
- 状態は可能な限りView Modelで保ち、複数の画面をまたいで必要な共有状態は`Provider`で管理する。
- UIロジックとビジネスロジックは明確に分離する。
- ビジネスロジックは`domain`フォルダに配置する。
  - Value Objectは`domain/models/vo`に配置する。
    - Value Objectは`freezed`アノテーションを使用する。
    - Value ObjectはDartで定義された型（`int`, `String`, `List`など）のプロパティをただひとつ持つ。
    - Value Objectは`Assert`アノテーションを使用して誓約を定義する。
  - Entityは`domain/models`に配置する。
    - Entityは`freezed`アノテーションを使用する。
    - Entityはひとつ以上のValue Objectをプロパティとして持つ。
    - Entityは`Assert`アノテーションを使用して誓約を定義する。
  - Use caseは導入しない。
    - 現時点では、ViewModelにビジネスロジックを集約し、コードの冗長化を避けることを優先する。
    - ロジックが肥大化・再利用性が必要になった場合に、段階的にUseCaseの導入を検討する。
  - Repository interfaceは`domain/repository`に配置する。
    - RepositoryはSingle source of truthであり、アプリケーションデータの信頼できる単一の情報源である。
    - とある種類のValue objectまたはEntityを取得できるのは、ひとつのRepositoryだけである。
      - Repositoryのメソッドによって、ひとつだけ取得する場合やListで取得することは許可される。
- データレイヤーの実装は`data`フォルダに配置する。
  - Repositoryの実装は`data/repository`に配置する。
  - 外部サービスから取得したデータを表現する型は、`data/models`に配置する。
    - 外部サービスから取得したデータを表現する型は、`freezed`アノテーションを使用する。
- プレゼンテーションレイヤーの実装は`presentation`フォルダに配置する。
  - 機能ごとに、`presentation/pages`フォルダに配置する。
    - View Modelは`presentation/pages/feature/view_model.dart`に配置する。
      - View ModelがRepositoryのメソッドを呼び出すときはCommandを使用し、実行状態をUIへ通知できるようにする。
      - View Modelは基本的に[ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)をMixinで使用する。
        - ただし、View Modelが提供する状態が単純であれば[ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html)の使用も可能。
    - Pageは`presentation/pages/feature/page.dart`に配置する。
      - Pageと名前がついたWidgetは[Scaffold](https://api.flutter.dev/flutter/material/Scaffold-class.html)を返す。
    - そのページで使用するWidgetは`presentation/pages/feature/widgets`に配置する。
    - PageとView Modelは1対1関係である。
  - ルーティングはネイティブの[Navigator API](https://docs.flutter.dev/ui/navigation#using-the-navigator)を使用する。
    - ここはそのうちGoRouterに移行したい。
  - 一般的なCommandは`presentation/pages/commands/command.dart`に配置する。
  - 共通して使われるWidgetは`presentation/widgets`に配置する。

---

## 5. テストポリシー

本プロジェクトのテストは、ドキュメント管理ポリシーおよび設計ルールに基づき、以下の方針で実施・管理する。

| 種別 | 目的・内容 | 必須度 | 保存先・管理方法 | 記述方針 |
|------|------------|--------|------------------|----------|
| **ユニットテスト** | ビジネスロジック・状態変化の検証（モデル・ViewModel等） | ◎ | `/test/domain/`（ドメイン層）、`/test/data/`（データ層） | Test as a specificationで「何をしているか」を記述。ドメイン層はSRP・DIP等の設計ルールを遵守。|
| **Widgetテスト** | ユーザー操作・画面遷移の仕様定義 | ◎ | `/test/presentation/`（Widgetテスト）| Test as a specificationでユーザー操作・UI仕様を記述。|
| **Integrationテスト** | UIとロジックの結合確認（画面単位） | ◯ | `/integration_test/` | 画面ごとに少なくとも1件。状態遷移・画面遷移等の仕様をテストで明示。|
| **E2Eテスト（任意）** | 実デバイスでの動作確認 | △ | `/integration_test/` ほか | デプロイ前の動作確認用。|

### テスト記述・管理に関するルール
- テストは「何をしているか（What）」を明確に記述する（Test as a specification）。
- プロダクションコードのコメントには「なぜそうしているか（Why）」を記載する。
- 各テストは対応するコンポーネント仕様・UI/UXフロー・設計ルールと整合を取る。
- テストコードの配置は、ドキュメント管理ポリシーの「ライブドキュメント型」ルールに従う。
- テストの仕様がドキュメントを兼ねる場合、テストコード自体が仕様書となる。
- テストの追加・修正時は、関連するドキュメント（例: `/docs/architecture.md`, `/docs/firestore_schema.md`）も必要に応じて更新する。

> 詳細な設計ルールやテスト配置の例は「4. 設計ルール」「1. ドキュメント管理ポリシー」も参照。

---

## 6. 新規参画者向け情報

### 🔹 Git / ブランチ戦略
- ブランチ命名：`dev/xxx`

### 🔹 使用ライブラリ

#### プロダクション

- Provider
  - 依存性注入
  - 複数画面にわたる状態管理
  - 代替候補
    - RiverPod
- fl_chart
  - グラフ表示
- dartz
  - Resultパターンのために使いたい
  - 最近更新されていないのが懸念
  - 代替候補補
    - [result_dart](https://pub.dev/packages/result_dart)
- equatable
  - 今はほとんどfreezedでやっている
  - 新しく書くコードでは使用しない
- get_it
  - 依存性注入
  - 現在は使用していない。新しく書くコードではProviderを使用する
- logging
  - ログのために使いたいがほとんど使っていない

#### テスト

- mockito
  - モック化

### 🔹 推奨されるコード例 / アンチパターン
- 今はなし

---

## 7. 参考リンク

- [Flutter公式ドキュメント](https://flutter.dev/)
- [Mermaid記法リファレンス](https://mermaid.js.org/)
- [Test as Specificationとは](https://martinfowler.com/bliki/SpecificationByExample.html)
