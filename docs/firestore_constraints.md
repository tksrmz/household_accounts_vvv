# Firestore データ制約一覧

このドキュメントは、家計簿アプリのFirestoreデータベースにおける各コレクションとドキュメントの制約を明示的に定義しています。これは[firestore_schema.md](./firestore_schema.md)を補完するドキュメントです。

## 目的

このドキュメントの目的は以下の通りです：

1. データの整合性を確保するためのビジネスルールを明文化する
2. Firestoreセキュリティルールの根拠となる制約を明確にする
3. アプリケーション開発時の参照資料として利用する
4. AIコーディングエージェントがデータモデルを正確に理解できるようにする

## テーブル制約一覧

### 1. 公開プロフィール (publicProfiles)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| name | 1-20文字の必須項目 | UX要件、表示領域の制限 | Firestore Rules, ドメインモデル |
| createdAt | 必須項目、自動生成 | データ整合性、監査証跡 | Repository実装 |
| updatedAt | 必須項目、更新時に自動更新 | データ整合性、監査証跡 | Repository実装 |

### 2. 非公開プロフィール (privateProfiles)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| sharedNote | 任意項目、有効な参照パスのみ許可 | データ整合性 | Firestore Rules |
| アクセス制御 | 所有者のみ読み書き可能 | プライバシー保護 | Firestore Rules |

### 3. 収入カテゴリ (incomeCategories)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| name | 1-20文字の必須項目 | UX要件、表示領域の制限 | Firestore Rules, ドメインモデル |
| type | "income"固定値 | データ整合性 | Repository実装 |
| 削除制約 | 関連する収入レコードが存在する場合は削除不可 | 参照整合性 | アプリケーションロジック |

### 4. 支出カテゴリ (expenseCategories)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| name | 1-20文字の必須項目 | UX要件、表示領域の制限 | Firestore Rules, ドメインモデル |
| type | "expense"固定値 | データ整合性 | Repository実装 |
| totalBudget | 0以上の整数、必須項目 | ビジネスルール | Firestore Rules, ドメインモデル |
| 削除制約 | 関連する支出レコードが存在する場合は削除不可 | 参照整合性 | アプリケーションロジック |

### 5. 資産 (properties)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| name | 1-20文字の必須項目 | UX要件、表示領域の制限 | Firestore Rules, ドメインモデル |
| amount | 整数値、必須項目 | データ型の一貫性 | Firestore Rules, ドメインモデル |
| 削除制約 | 関連する収入/支出/振替レコードが存在する場合は削除不可 | 参照整合性 | アプリケーションロジック |
| 残高更新 | 収入/支出/振替発生時に自動更新 | データ整合性 | Repository実装 |

### 6. 収入レコード (incomes)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| date | 必須項目、未来日付は禁止 | データ整合性 | Firestore Rules, ドメインモデル |
| amount | 0より大きい整数、必須項目 | ビジネスルール | Firestore Rules, ドメインモデル |
| note | 100文字以下、必須項目 | UX要件 | Firestore Rules, ドメインモデル |
| createdAt | 必須項目、自動生成 | データ整合性、監査証跡 | Repository実装 |
| hasCheckedOut | 必須項目、常にtrue(残高へ反映済みであることを表す) | ビジネスルール | Repository実装 |
| type | "income"固定値 | データ整合性 | Repository実装 |
| property | 有効な資産への参照、必須項目 | 参照整合性 | Firestore Rules, Repository実装 |
| category | 有効な収入カテゴリへの参照、必須項目 | 参照整合性 | Firestore Rules, Repository実装 |
| 資産更新 | 作成時に対応する資産の残高を増加 | データ整合性 | Repository実装 |

### 7. 支出レコード (expenses)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| date | 必須項目、未来日付は禁止 | データ整合性 | Firestore Rules, ドメインモデル |
| amount | 0より大きい整数、必須項目 | ビジネスルール | Firestore Rules, ドメインモデル |
| note | 100文字以下、必須項目 | UX要件 | Firestore Rules, ドメインモデル |
| createdAt | 必須項目、自動生成 | データ整合性、監査証跡 | Repository実装 |
| hasCheckedOut | 必須項目、常にtrue(残高へ反映済みであることを表す) | ビジネスルール | Repository実装 |
| type | "expense"固定値 | データ整合性 | Repository実装 |
| property | 有効な資産への参照、必須項目 | 参照整合性 | Firestore Rules, Repository実装 |
| category | 有効な支出カテゴリへの参照、必須項目 | 参照整合性 | Firestore Rules, Repository実装 |
| 資産更新 | 作成時に対応する資産の残高を減少 | データ整合性 | Repository実装 |
| 予算チェック | カテゴリの予算を超過する場合は警告（禁止ではない） | UX要件 | アプリケーションロジック |

### 8. 振替レコード (transfers)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| date | 必須項目、未来日付は禁止 | データ整合性 | Firestore Rules, ドメインモデル |
| amount | 0より大きい整数、必須項目 | ビジネスルール | Firestore Rules, ドメインモデル |
| note | 100文字以下、必須項目 | UX要件 | Firestore Rules, ドメインモデル |
| createdAt | 必須項目、自動生成 | データ整合性、監査証跡 | Repository実装 |
| hasCheckedOut | 必須項目、常にtrue(残高へ反映済みであることを表す) | ビジネスルール | Repository実装 |
| type | "transfer"固定値 | データ整合性 | Repository実装 |
| fromProperty | 有効な資産への参照、必須項目 | 参照整合性 | Firestore Rules, Repository実装 |
| toProperty | 有効な資産への参照、必須項目 | 参照整合性 | Firestore Rules, Repository実装 |
| 同一資産禁止 | fromPropertyとtoPropertyは異なる必要がある | ビジネスルール | Firestore Rules, ドメインモデル |
| 資産更新 | 作成時にfromPropertyの残高を減少、toPropertyの残高を増加 | データ整合性 | Repository実装 |

### 9. 共有ノート (sharedNotes)

| 制約 | 内容 | 理由 | 実装場所 |
|------|------|------|----------|
| owners | 有効なユーザーIDの配列、少なくとも1つ以上 | アクセス制御 | Firestore Rules |
| アクセス制御 | owners配列に含まれるユーザーのみ読み書き可能 | セキュリティ | Firestore Rules |

## トランザクション要件

以下の操作はトランザクション内で実行する必要があります：

1. **収入レコード作成/更新/削除**: 関連する資産の残高更新を含む
2. **支出レコード作成/更新/削除**: 関連する資産の残高更新を含む
3. **振替レコード作成/更新/削除**: 関連する2つの資産の残高更新を含む
4. **資産削除**: 関連するレコードの有無確認を含む
5. **カテゴリ削除**: 関連するレコードの有無確認を含む

## 実装上の注意点

1. **整合性確保**:
   - 資産残高は常にレコードの合計と一致する必要がある
   - 参照整合性は常に維持する必要がある

2. **セキュリティ**:
   - 個人ノートは所有者のみアクセス可能
   - 共有ノートはowners配列に含まれるユーザーのみアクセス可能
   - プロフィール情報の公開/非公開を適切に分離

## 変更履歴

- 2025-05-24: 初版作成
