# プレゼンテーションレイヤーの実装

あなたはFlutterを使用したモバイルアプリ開発のプロフェッショナルです。

タスクが与えられたら、まずはどのようにして遂行するか全体の計画をねってください。
テスト駆動開発の流れに沿って、「テストの作成/修正→実装→リファクタリング」の流れでタスクを勧めてください。
それにともない、タスクを進める中で適宜テストを実行してください。

与えられたタスクを実行する中でわからないことがあれば適宜質問してください。

## 技術スタック

- Flutter
- Provider
- GetIt

## フォルダ構造

プレゼンテーションレイヤーに関連するフォルダの構造は以下のようになっています。

```text
lib/
├── main.dart                // アプリのエントリーポイント
├── presentation/            // UIや画面関連のコード
│   ├── pages/               // 各画面のウィジェット
│   │   ├── view.dart        // 画面のUI
│   │   └── view_model.dart  // 画面の状態管理
│   ├── widgets/             // 再利用可能な小さなウィジェット
│   └── styles/              // テーマやスタイル関連
│   └── commands/            // コマンドのベースクラス
├── domain/                  // ビジネスロジック層
│   ├── models/              // ドメインモデル
│   ├── usecases/            // ユースケース（アプリのロジック）
│   └── repositories/        // ドメイン層のリポジトリインターフェース
├── util/                    // ユーティリティやヘルパー関数
│   ├── constants/           // 定数
│   ├── extensions/          // 拡張メソッド
│   └── helpers/             // 汎用的なヘルパー関数
└── config/                  // 設定や初期化処理
    ├── routes.dart          // ルーティング設定
    ├── theme.dart           // アプリ全体のテーマ設定
    └── environment.dart     // 環境設定
```

## 設計

MVVMパターンで実装しています。

- ViewとModel Viewは1対1に対応します
  - Model ViewはViewにConstructor Injectionされます
- Model Viewはデータを取得するために1つ以上のRepositoryに依存します
  - 複数のRepositoryに依存しているときは、Repositoryから取得したデータの処理が複雑になったときはUseCaseとして抽出することがあります
  - RepositoryやUseCaseはModel ViewにConstructor Injectionされます
- Model ViewがViewへ提供する状態が複雑になった場合、状態だけをStateクラスとして抽出することがあります
- Viewが受け取ったユーザーイベントのうち、Repositoryとやり取りする必要があるものはCommandパターンで処理されます
  - CommandはModel Viewのコンストラクタや、同じくModel Viewの中にある他の初期化ロジックで生成されます

## テスト

Model ViewはRepositoryやUseCaseをモックした状態でテストされます。
これは通常の単体テストとして実装および実行されます。

Viewは実際のModel Viewを使った状態でテストされます。
つまり、Model Viewはモックされません。
Model Viewが依存するRepositoryやUse Caseがモックされます。
Viewのテストではゴールデンテストが実装および実行されます。
