# 家計簿アプリ アーキテクチャ概要

## アーキテクチャ図

```mermaid
graph TD
    %% Define nodes with better styling
    A["View"]:::viewStyle
    B["ViewModel"]:::viewModelStyle
    C["Repository Interface"]:::repoStyle
    D["Repositories"]:::dataStyle
    SV["Services"]:::serviceStyle
    E["Firebase Services"]:::firebaseStyle
    G["Firestore"]:::firestoreStyle
    H["Firebase Auth"]:::authStyle
    I["Cloud Functions"]:::functionsStyle

    %% Application subgraph with better spacing
    subgraph アプリケーション
        subgraph プレゼンテーションレイヤー
            A <-->|"1:1関係"| B
        end

        subgraph ドメインレイヤー
            B -->|"データ取得"| C
        end

        subgraph データレイヤー
            D -->|"実装"| C
            D -->|"利用"| SV
            SV -->|"通信"| E
        end
    end

    %% Firebase backend subgraph
    subgraph Firebaseバックエンド
        E --> H
        I -->|"監視"| G
        E --> G
    end

    %% Enhanced styling for subgraphs and connections
    classDef viewStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#01579b,font-weight:bold
    classDef viewModelStyle fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#2e7d32,font-weight:bold
    classDef repoStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#e65100,font-weight:bold
    classDef dataStyle fill:#f3e5f5,stroke:#6a1b9a,stroke-width:2px,color:#6a1b9a,font-weight:bold
    classDef serviceStyle fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#2e7d32,font-weight:bold
    classDef firebaseStyle fill:#ffebee,stroke:#c62828,stroke-width:2px,color:#c62828,font-weight:bold
    classDef firestoreStyle fill:#ffe0b2,stroke:#ef6c00,stroke-width:2px,color:#ef6c00,font-weight:bold
    classDef authStyle fill:#e3f2fd,stroke:#0d47a1,stroke-width:2px,color:#0d47a1,font-weight:bold
    classDef functionsStyle fill:#e8eaf6,stroke:#303f9f,stroke-width:2px,color:#303f9f,font-weight:bold

    %% Subgraph styling
    style アプリケーション fill:#f5f5f5,stroke:#424242,stroke-width:2px,color:#212121,font-weight:bold
    style Firebaseバックエンド fill:#fff8e1,stroke:#ff8f00,stroke-width:2px,color:#ff6f00,font-weight:bold
    style プレゼンテーションレイヤー fill:#e1f5fe,stroke:#01579b,stroke-width:1px,color:#01579b
    style ドメインレイヤー fill:#fff3e0,stroke:#e65100,stroke-width:1px,color:#e65100
    style データレイヤー fill:#f3e5f5,stroke:#6a1b9a,stroke-width:1px,color:#6a1b9a
```

## アーキテクチャの説明

### 1. プレゼンテーションレイヤー
- **View**: UIを構築するウィジェット
  - アプリケーションデータをユーザーに表示する方法を記述
  - Flutterウィジェットの組み合わせで機能を構成
  - ユーザー操作に応じてイベントをViewModelに渡す役割を持つ
  - ビジネスロジックは含まず、単純な条件分岐、アニメーション、レイアウト、ルーティングのみを含む
- **ViewModel**: UIの状態管理とビジネスロジックの呼び出し
  - Repositoryからデータを取得し、UI表示用に適切な形式に変換
  - Viewが必要とする状態を管理し、データを失わずに再描画を可能にする
  - コマンド（コールバック関数）をViewに提供し、ボタン押下やフォーム送信などのイベントハンドラに接続できるようにする

  ※ ViewとViewModelは1:1の関係を持ち、一つの機能（フィーチャー）を定義します。

### 2. ドメインレイヤー
- **Repository Interface**: データ操作の抽象化
  - 実装の詳細を隠し、データアクセスのためのインターフェースを定義
  - 具体的なデータソースからビジネスロジックを分離
  - ドメインモデルとエンティティを定義
  - Single Source of Truthであり、アプリケーションデータの信頼できる単一の情報源
  - アプリケーション全体で一貫したデータ状態を維持
  - 複数のViewModelが参照する共通のデータソースを提供

  ※ Repositoryの一部はインターフェースとしてDomain Layerに定義され、実装はData Layerに配置されます。

### 3. データレイヤー
- **Data Sources**: リポジトリの具象実装＆ローカルDBやAPIとの連携
  - **Repositories**: アプリケーションデータの信頼できる情報源（source of truth）。サービスからデータを取得し、ドメインモデルに変換する役割を持つ。キャッシュ、エラーハンドリング、リトライロジック、データの更新などのビジネスロジックを処理する。
  - **Services**: アプリケーションの最下層に位置し、APIエンドポイントをラップして非同期レスポンスオブジェクト（Future、Streamなど）を提供する。データの読み込みを分離するためだけに使用され、状態を保持しない。

  ※ Flutter公式アーキテクチャガイドでは、RepositoriesとServicesは別々のコンポーネントとして定義されていますが、本プロジェクトではこれらを「Data Layer」としてまとめています。

### 4. インフラストラクチャ
- **Firebase Services**: クラウドサービス連携
  - **Firestore**: ドキュメントデータベース
  - **Firebase Authentication**: ユーザー認証
  - **Cloud Functions**: サーバーレス関数

## 特徴
- 依存関係は内側から外側に向かう
- 各レイヤーは独立してテスト可能
- ビジネスロジックはUIやデータソースから分離
- Firebaseをバックエンドサービスとして活用

## ディレクトリ構造

```
household_accounts/
├── lib/
│   └── v2/
│       ├── presentation/    # プレゼンテーション層
│       ├── domain/         # ドメイン層
│       └── data/           # データ層
└── ...

household_accounts_firebase/
├── firestore.rules      # Firestoreセキュリティルール
├── firebase.json        # Firebase設定
└── functions/           # Cloud Functions
    └── src/
        └── index.ts  # バックエンドロジック
```

※ このドキュメントはプロジェクトの`v2`ディレクトリと`household_accounts_firebase`の構造に基づいています。
