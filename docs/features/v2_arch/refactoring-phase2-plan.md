# Phase2 実行計画: データレイヤー統一

## 概要

Phase2では、レガシーのRepository実装をV2パターンに移行します。これには以下の作業が含まれます：

1. V2データモデル（freezed）の作成
2. FirestoreServiceの拡張
3. Repository実装のV2パターン移行
4. ドメインRepositoryインターフェースの調整

## 現状分析

### V2データレイヤーパターン（目標）

**特徴:**

- **V2データモデル**: freezedベースの不変オブジェクト、fromJson/toJsonメソッド内蔵
- **FirestoreService**: 低レベルデータアクセス専用、データモデルを活用
- **Repository実装**: シンプル（30行程度）、FirestoreServiceを利用、Either<Exception, T>パターン
- **明確な責務分離**: Service（データアクセス）↔ Repository（ドメインモデル変換）

**実装例:**

```dart
// V2データモデル
@freezed
class IncomeRecordModel with _$IncomeRecordModel {
  const factory IncomeRecordModel({
    required String id,
    required DateTime date,
    required int amount,
    required String note,
    required bool hasCheckedOut,
    required String propertyRef,
    required String categoryRef,
  }) = _IncomeRecordModel;

  factory IncomeRecordModel.fromJson(Map<String, dynamic> json) =>
      _$IncomeRecordModelFromJson(json);
}

// Repository実装
class FirestorePersonalIncomeRepository implements IncomeRepository {
  @override
  Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date) async {
    final result = await _firestoreService.fetchMonthlyPersonalIncomes(_uid, date.year, date.month);
    return result.map((incomeModels) => 
      incomeModels.map((model) => IncomeVo(model.amount)).toList(growable: false)
    );
  }
}
```

### レガシーデータレイヤーパターン（現状）

**問題点:**

- **複雑なRepository実装**: 200行以上の実装、Transaction処理がRepository内部にある
- **独自型**: ExceptionOr<T>という独自エラーハンドリング型
- **複雑なModelクラス**: Firebase特有の変換ロジックがRepository内部に混在
- **古いEntityパターン**: equatableベース

**課題:**

```dart
class FirebasePersonalIncomeRecordRepository implements PersonalIncomeRecordRepository {
  // 内部でTransactionHandlerを直接操作
  Future<ExceptionOr<Unit>> register(...) async {
    final batch = FirebaseFirestore.instance.batch();
    // 複雑なbatch処理
    try {
      await batch.commit();
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(e);
    }
  }
}
```

## 移行対象ファイル

### Repository実装（8ファイル）

| レガシーファイル | 移行先 | 責務 |
|------------------|--------|------|
| `firebase_income_record_repository.dart` | `v2/data/repositories/firestore/personal_income_repository.dart`<br>`v2/data/repositories/firestore/shared_income_repository.dart` | 収入レコード管理（個人/共有） |
| `firebase_expense_record_repository.dart` | `v2/data/repositories/firestore/personal_expense_repository.dart`<br>`v2/data/repositories/firestore/shared_expense_repository.dart` | 支出レコード管理（個人/共有） |
| `firebase_transfer_record_repository.dart` | `v2/data/repositories/firestore/transfer_repository.dart` | 振替レコード管理 |
| `firebase_income_category_repository.dart` | `v2/data/repositories/firestore/income_category_repository.dart` | 収入カテゴリ管理 |
| `firebase_expense_category_repository.dart` | `v2/data/repositories/firestore/expense_category_repository.dart` | 支出カテゴリ管理 |
| `firebase_property_repository.dart` | `v2/data/repositories/firestore/property_repository.dart` | 資産管理 |

### V2データモデル（新規作成、6ファイル）

| 新規ファイル | 責務 |
|-------------|------|
| `v2/data/models/income_record_model.dart` | 収入レコードFirestoreモデル |
| `v2/data/models/expense_record_model.dart` | 支出レコードFirestoreモデル |
| `v2/data/models/transfer_record_model.dart` | 振替レコードFirestoreモデル |
| `v2/data/models/income_category_model.dart` | 収入カテゴリFirestoreモデル |
| `v2/data/models/expense_category_model.dart` | 支出カテゴリFirestoreモデル |
| `v2/data/models/property_model.dart` | 資産Firestoreモデル |

### 削除対象ファイル（6ファイル）

| レガシーファイル | 削除理由 |
|------------------|----------|
| `record_model.dart` | V2データモデルに置換 |
| `category_model.dart` | V2データモデルに置換 |
| `property_model.dart` | V2データモデルに置換 |
| `data_model.dart` | V2では不要 |
| `util/path_builder.dart` | FirestoreServiceに統合 |
| `util/collection_reference_builder.dart` | V2では不要 |

### ドメインインターフェース調整

| レガシーインターフェース | V2対応 |
|-------------------------|--------|
| `feature/repository/record_repository.dart` | 新規V2インターフェース作成 |
| `feature/repository/category_repository.dart` | 新規V2インターフェース作成 |
| `feature/repository/property_repository.dart` | 新規V2インターフェース作成 |

## 実行タスク

### Task 2.1: V2データモデル作成

**目的**: レガシーModelクラスをV2 freezedパターンで再実装

**サブタスク:**

1. **Task 2.1.1: レコード系モデル作成**

   ```dart
   // lib/v2/data/models/income_record_model.dart
   @freezed
   class IncomeRecordModel with _$IncomeRecordModel {
     const factory IncomeRecordModel({
       required String id,
       required DateTime date,
       required int amount,
       required String note,
       required bool hasCheckedOut,
       required DateTime createdAt,
       required String propertyRef,
       required String categoryRef,
       @Default('income') String type,
     }) = _IncomeRecordModel;

     factory IncomeRecordModel.fromJson(Map<String, dynamic> json) =>
         _$IncomeRecordModelFromJson(json);
   }

   // lib/v2/data/models/expense_record_model.dart
   @freezed
   class ExpenseRecordModel with _$ExpenseRecordModel {
     const factory ExpenseRecordModel({
       required String id,
       required DateTime date,
       required int amount,
       required String note,
       required bool hasCheckedOut,
       required DateTime createdAt,
       required String propertyRef,
       required String categoryRef,
       @Default('expense') String type,
     }) = _ExpenseRecordModel;

     factory ExpenseRecordModel.fromJson(Map<String, dynamic> json) =>
         _$ExpenseRecordModelFromJson(json);
   }

   // lib/v2/data/models/transfer_record_model.dart
   @freezed
   class TransferRecordModel with _$TransferRecordModel {
     const factory TransferRecordModel({
       required String id,
       required DateTime date,
       required int amount,
       required String note,
       required bool hasCheckedOut,
       required DateTime createdAt,
       required String fromPropertyRef,
       required String toPropertyRef,
       @Default('transfer') String type,
     }) = _TransferRecordModel;

     factory TransferRecordModel.fromJson(Map<String, dynamic> json) =>
         _$TransferRecordModelFromJson(json);
   }
   ```

2. **Task 2.1.2: カテゴリ系モデル作成**

   ```dart
   // lib/v2/data/models/income_category_model.dart
   @freezed
   class IncomeCategoryModel with _$IncomeCategoryModel {
     const factory IncomeCategoryModel({
       required String id,
       required String name,
       @Default('income') String type,
     }) = _IncomeCategoryModel;

     factory IncomeCategoryModel.fromJson(Map<String, dynamic> json) =>
         _$IncomeCategoryModelFromJson(json);
   }

   // lib/v2/data/models/expense_category_model.dart
   @freezed
   class ExpenseCategoryModel with _$ExpenseCategoryModel {
     const factory ExpenseCategoryModel({
       required String id,
       required String name,
       required int totalBudget,
       @Default('expense') String type,
     }) = _ExpenseCategoryModel;

     factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) =>
         _$ExpenseCategoryModelFromJson(json);
   }
   ```

3. **Task 2.1.3: 資産モデル作成**

   ```dart
   // lib/v2/data/models/property_model.dart
   @freezed
   class PropertyModel with _$PropertyModel {
     const factory PropertyModel({
       required String id,
       required String name,
       required int amount,
     }) = _PropertyModel;

     factory PropertyModel.fromJson(Map<String, dynamic> json) =>
         _$PropertyModelFromJson(json);
   }
   ```

**推定工数**: 2日

### Task 2.2: FirestoreServiceの拡張

**目的**: 新しいV2データモデルを活用してFirestoreServiceを拡張

**サブタスク:**

1. **Task 2.2.1: カテゴリ関連メソッド追加**

   ```dart
   // 収入カテゴリ
   Future<Either<Exception, List<IncomeCategoryModel>>> fetchPersonalIncomeCategories(UserIdVo userId);
   Future<Either<Exception, Unit>> addPersonalIncomeCategory(UserIdVo userId, IncomeCategoryModel category);
   Future<Either<Exception, Unit>> updatePersonalIncomeCategory(UserIdVo userId, String categoryId, IncomeCategoryModel category);
   Future<Either<Exception, Unit>> deletePersonalIncomeCategory(UserIdVo userId, String categoryId);

   // 支出カテゴリ
   Future<Either<Exception, List<ExpenseCategoryModel>>> fetchPersonalExpenseCategories(UserIdVo userId);
   // その他CRUD操作
   ```

2. **Task 2.2.2: 資産関連メソッド追加**

   ```dart
   Future<Either<Exception, List<PropertyModel>>> fetchPersonalProperties(UserIdVo userId);
   Future<Either<Exception, Unit>> addPersonalProperty(UserIdVo userId, PropertyModel property);
   Future<Either<Exception, Unit>> updatePersonalProperty(UserIdVo userId, String propertyId, PropertyModel property);
   Future<Either<Exception, Unit>> deletePersonalProperty(UserIdVo userId, String propertyId);
   ```

3. **Task 2.2.3: レコード関連メソッド拡張**

   ```dart
   // 支出レコード
   Future<Either<Exception, List<ExpenseRecordModel>>> fetchPersonalExpenses(UserIdVo userId, int year, [int? month, int? day]);
   Future<Either<Exception, Unit>> addPersonalExpense(UserIdVo userId, ExpenseRecordModel expense);
   Future<Either<Exception, Unit>> deletePersonalExpense(UserIdVo userId, String expenseId);

   // 振替レコード
   Future<Either<Exception, List<TransferRecordModel>>> fetchPersonalTransfers(UserIdVo userId, int year, [int? month, int? day]);
   Future<Either<Exception, Unit>> addPersonalTransfer(UserIdVo userId, TransferRecordModel transfer);
   Future<Either<Exception, Unit>> deletePersonalTransfer(UserIdVo userId, String transferId);
   ```

4. **Task 2.2.4: Transaction処理メソッド追加**

   ```dart
   Future<Either<Exception, Unit>> executeTransaction(
     Future<void> Function(Transaction transaction) transactionHandler
   );
   ```

**推定工数**: 2日

### Task 2.3: V2 Repository Interface作成

**目的**: レガシーのRepository InterfaceをV2パターンに変換

**サブタスク:**

1. **Task 2.3.1: カテゴリRepository Interface**

   ```dart
   // lib/v2/domain/repositories/income_category_repository.dart
   abstract interface class IncomeCategoryRepository {
     Future<Either<Exception, List<IncomeCategoryVo>>> fetchAll();
     Future<Either<Exception, Unit>> add(IncomeCategoryVo category);
     Future<Either<Exception, Unit>> update(CategoryIdVo id, IncomeCategoryVo category);
     Future<Either<Exception, Unit>> delete(CategoryIdVo id);
   }

   // lib/v2/domain/repositories/expense_category_repository.dart
   abstract interface class ExpenseCategoryRepository {
     Future<Either<Exception, List<ExpenseCategoryVo>>> fetchAll();
     Future<Either<Exception, Unit>> add(ExpenseCategoryVo category);
     Future<Either<Exception, Unit>> update(CategoryIdVo id, ExpenseCategoryVo category);
     Future<Either<Exception, Unit>> delete(CategoryIdVo id);
   }
   ```

2. **Task 2.3.2: 資産Repository Interface**

   ```dart
   // lib/v2/domain/repositories/property_repository.dart
   abstract interface class PropertyRepository {
     Future<Either<Exception, List<PropertyVo>>> fetchAll();
     Future<Either<Exception, Unit>> add(PropertyVo property);
     Future<Either<Exception, Unit>> update(PropertyIdVo id, PropertyVo property);
     Future<Either<Exception, Unit>> delete(PropertyIdVo id);
   }
   ```

3. **Task 2.3.3: レコードRepository Interface拡張**

   ```dart
   // 既存のIncomeRepositoryを拡張
   abstract interface class IncomeRepository {
     Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date);
     Future<Either<Exception, Unit>> add(IncomeRecordVo record);  // 新規
     Future<Either<Exception, Unit>> delete(RecordIdVo id);       // 新規
   }

   // lib/v2/domain/repositories/expense_repository.dart - 新規作成
   abstract interface class ExpenseRepository {
     Future<Either<Exception, List<ExpenseVo>>> fetchMonthly(DateTime date);
     Future<Either<Exception, Unit>> add(ExpenseRecordVo record);
     Future<Either<Exception, Unit>> delete(RecordIdVo id);
   }

   // lib/v2/domain/repositories/transfer_repository.dart - 新規作成
   abstract interface class TransferRepository {
     Future<Either<Exception, List<TransferVo>>> fetchMonthly(DateTime date);
     Future<Either<Exception, Unit>> add(TransferRecordVo record);
     Future<Either<Exception, Unit>> delete(RecordIdVo id);
   }
   ```

**推定工数**: 1日

### Task 2.4: V2 Repository実装作成

**目的**: V2パターンでのRepository実装を作成

**サブタスク:**

1. **Task 2.4.1: カテゴリRepository実装**

   ```dart
   // lib/v2/data/repositories/firestore/income_category_repository.dart
   class FirestoreIncomeCategoryRepository implements IncomeCategoryRepository {
     final FirestoreService _firestoreService;
     final UserIdVo _uid;

     @override
     Future<Either<Exception, List<IncomeCategoryVo>>> fetchAll() async {
       final result = await _firestoreService.fetchPersonalIncomeCategories(_uid);
       return result.map((categoryModels) => 
         categoryModels.map((model) => IncomeCategoryVo(
           id: CategoryIdVo(model.id),
           name: CategoryNameVo(model.name),
         )).toList(growable: false)
       );
     }

     @override
     Future<Either<Exception, Unit>> add(IncomeCategoryVo category) async {
       final model = IncomeCategoryModel(
         id: category.id.value,
         name: category.name.value,
       );
       return _firestoreService.addPersonalIncomeCategory(_uid, model);
     }

     // その他CRUD操作
   }
   ```

2. **Task 2.4.2: 資産Repository実装**

3. **Task 2.4.3: レコードRepository実装拡張**

   - 既存のIncomeRepositoryにadd/deleteメソッド追加
   - ExpenseRepository実装作成
   - TransferRepository実装作成

**推定工数**: 2日

### Task 2.5: Value Object作成

**目的**: 新しいRepository操作に必要なValue Objectを作成

**必要なVO:**

1. **カテゴリ関連**

   ```dart
   // lib/v2/domain/models/vo/income_category.dart
   @freezed
   class IncomeCategoryVo with _$IncomeCategoryVo {
     factory IncomeCategoryVo({
       required CategoryIdVo id,
       required CategoryNameVo name,
     }) = _IncomeCategoryVo;
   }

   // lib/v2/domain/models/vo/expense_category.dart
   @freezed
   class ExpenseCategoryVo with _$ExpenseCategoryVo {
     factory ExpenseCategoryVo({
       required CategoryIdVo id,
       required CategoryNameVo name,
       required BudgetAmountVo totalBudget,
     }) = _ExpenseCategoryVo;
   }
   ```

2. **レコード関連**

   ```dart
   // lib/v2/domain/models/vo/income_record.dart
   @freezed
   class IncomeRecordVo with _$IncomeRecordVo {
     factory IncomeRecordVo({
       required RecordIdVo id,
       required RecordDateVo date,
       required RecordAmountVo amount,
       required RecordNoteVo note,
       required PropertyIdVo propertyId,
       required CategoryIdVo categoryId,
     }) = _IncomeRecordVo;
   }

   // ExpenseRecordVo, TransferRecordVo同様
   ```

**推定工数**: 1日

### Task 2.6: テスト作成

**目的**: 移行したRepository実装のテスト作成

**サブタスク:**

1. **Task 2.6.1: データモデルテスト作成**

   - freezedモデルのfromJson/toJsonテスト

2. **Task 2.6.2: FirestoreServiceテスト拡張**

   - 新規追加メソッドのテスト追加

3. **Task 2.6.3: Repository実装テスト作成**

   - カテゴリRepository実装テスト
   - 資産Repository実装テスト
   - レコードRepository実装テスト

**推定工数**: 1日

## 依存関係とリスク

### 依存関係

- **Phase1完了必須**: Value Objectの基盤となるクラスが完成している必要がある
- **並列実行可能**: Task 2.1-2.5は部分的に並列実行可能
- **順次実行**: Task 2.6はTask 2.1-2.5完了後

### リスク分析

| リスク | 影響度 | 軽減策 |
|--------|--------|--------|
| FirebaseTransaction処理の複雑性 | 高 | 段階的移行、既存処理の詳細分析 |
| freezedモデル設計の不整合 | 中 | 既存privateProfile.dartパターン踏襲 |
| レガシーRepository機能の見落とし | 中 | 詳細なコードレビュー、テストカバレッジ確保 |
| Firebase Emulatorsでのテスト限界 | 低 | 結合テスト強化、段階的本番検証 |

## 完了条件

### 技術条件

- [x] レガシーRepository実装8ファイルのV2移行完了
- [x] V2データモデル6ファイル作成完了
- [x] FirestoreServiceの全機能移植完了
- [x] 新規Value Object作成完了
- [x] 全移行済みRepositoryのテスト作成完了
- [x] 既存機能の動作確認完了

### 品質条件

- [x] V2アーキテクチャパターン100%準拠
- [x] Either<Exception, T>エラーハンドリング統一
- [x] テストカバレッジ80%以上
- [x] パフォーマンス劣化なし

## 次フェーズへの引き渡し

Phase2完了時、以下がPhase3に引き渡されます：

1. **完全なV2データレイヤー**: 全Repository実装がV2パターンに統一
2. **統一されたV2データモデル**: freezedベースの型安全なFirestoreモデル
3. **拡張されたFirestoreService**: 全アプリケーション機能に対応
4. **統一されたValue Objectセット**: 全データ型の型安全性確保
5. **包括的なテストスイート**: データレイヤーの品質保証

これにより、Phase3では安心してBusinessロジック層（Use Case削除、Commandパターン導入）に集中できます。

## 推定工数まとめ

| タスク | 工数 | 備考 |
|--------|------|------|
| Task 2.1: V2データモデル作成 | 2日 | freezed + json_annotation |
| Task 2.2: FirestoreService拡張 | 2日 | 複雑なTransaction処理含む |
| Task 2.3: Repository Interface作成 | 1日 | 設計作業中心 |
| Task 2.4: Repository実装作成 | 2日 | パターン適用作業 |
| Task 2.5: Value Object作成 | 1日 | freezed生成含む |
| Task 2.6: テスト作成 | 1日 | 品質保証 |

**合計推定工数**: 9日

この計画により、Phase2を体系的かつ確実に実行し、レガシーデータレイヤーをV2パターンに完全移行できます。
