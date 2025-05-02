以下のフォルダ構成で作り直す

```
lib/
├── main.dart                // アプリのエントリーポイント
├── presentation/            // UIや画面関連のコード
│   ├── pages/               // 各画面のウィジェット
│   ├── widgets/             // 再利用可能な小さなウィジェット
│   └── styles/              // テーマやスタイル関連
├── data/                    // データ層（APIやデータベース関連）
│   ├── models/              // データモデル
│   ├── repositories/        // データ取得ロジック
│   └── sources/             // データソース（APIやローカルDB）
├── domain/                  // ビジネスロジック層
│   ├── entities/            // ドメインエンティティ
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