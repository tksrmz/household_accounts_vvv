# 家計簿アプリ アーキテクチャ概要

## アーキテクチャ図

```mermaid
graph TD
    %% Define nodes with better styling
    A["View"]:::viewStyle
    B["ViewModel"]:::viewModelStyle
    C["Repository"]:::repoStyle
    D["Data Sources"]:::dataStyle
    E["Firebase Services"]:::firebaseStyle
    G["Firestore"]:::firestoreStyle
    H["Firebase Auth"]:::authStyle
    I["Cloud Functions"]:::functionsStyle

    %% Application subgraph with better spacing
    subgraph アプリケーション
        A -->|"ユーザー操作によるイベント通知"| B
        B -->|"インターフェースを介してデータ取得"| C
        D -->|"実装"| C
        D -->|"通信"| E
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
    classDef firebaseStyle fill:#ffebee,stroke:#c62828,stroke-width:2px,color:#c62828,font-weight:bold
    classDef firestoreStyle fill:#ffe0b2,stroke:#ef6c00,stroke-width:2px,color:#ef6c00,font-weight:bold
    classDef authStyle fill:#e3f2fd,stroke:#0d47a1,stroke-width:2px,color:#0d47a1,font-weight:bold
    classDef functionsStyle fill:#e8eaf6,stroke:#303f9f,stroke-width:2px,color:#303f9f,font-weight:bold

    %% Subgraph styling
    style アプリケーション fill:#f5f5f5,stroke:#424242,stroke-width:2px,color:#212121,font-weight:bold
    style Firebaseバックエンド fill:#fff8e1,stroke:#ff8f00,stroke-width:2px,color:#ff6f00,font-weight:bold
```

## アーキテクチャの説明

### 1. Presentation Layer (プレゼンテーション層)
- **View**: UIを構築するウィジェット
- **ViewModel**: UIの状態管理とビジネスロジックの呼び出し

### 2. Domain Layer (ドメイン層)
- **Repository Interface**: データ操作の抽象化

### 3. Data Layer (データ層)
- **Data Sources**: リポジトリの具象実装＆ローカルDBやAPIとの連携

### 4. Infrastructure (インフラストラクチャ)
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
