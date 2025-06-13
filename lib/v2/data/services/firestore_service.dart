import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/privateProfile.dart';
import 'package:household_accounts/v2/data/models/income_category_model.dart';
import 'package:household_accounts/v2/data/models/expense_category_model.dart';
import 'package:household_accounts/v2/data/models/income_record_model.dart';
import 'package:household_accounts/v2/data/models/expense_record_model.dart';
import 'package:household_accounts/v2/data/models/transfer_record_model.dart';
import 'package:household_accounts/v2/data/models/property_model.dart';

import '../../domain/models/vo/user_id.dart';
import '../../domain/models/vo/user_name.dart';

/// Firestoreと連携するためのサービス
class FirestoreService {
  final FirebaseFirestore _db;

  const FirestoreService(this._db);


  /// [userId]のユーザー名を取得する。
  Future<Either<Exception, Map<String, dynamic>>> fetchPublicProfileOf(
      UserIdVo userId) async {
    try {
      final documentReference = _db.doc('/publicProfiles/${userId.value}');
      final documentSnapshot = await documentReference.get();
      return Right(documentSnapshot.data()!);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]のユーザー名を更新する。
  Future<Either<Exception, Unit>> updatePublicProfileNameOf(
    UserIdVo userId,
    UserNameVo userName,
  ) async {
    try {
      final documentReference = _db.doc('/publicProfiles/${userId.value}');
      await documentReference.update({
        'name': userName.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// ユーザーのプライベートプロファイルを取得する。
  Future<Either<Exception, DocumentSnapshot<PrivateProfile>>>
      fetchPrivateProfileOf(
    UserIdVo userId,
  ) async {
    try {
      final documentSnapshot = await _db
          .doc('/privateProfiles/${userId.value}')
          .withConverter(
            fromFirestore: (snapshot, _) =>
                PrivateProfile.fromJson(snapshot.data()!),
            toFirestore: (data, _) => data.toFirestoreJson(),
          )
          .get();
      return Right(documentSnapshot);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// 共有ノートの指定された月のすべての支出を取得する。
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての支出を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての支出を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての支出を取得します。
  Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchMonthlySharedExpensesFrom(
    DocumentReference<Map<String, dynamic>> sharedNoteDocRef,
    int year, [
    int? month,
    int? day,
  ]) async {
    assert(
      (month != null && day != null) || // 全部指定
          (month != null && day == null) || // yearとmonth指定
          (month == null && day == null), // yearのみ指定
      'monthとdayの組み合わせが不適切です',
    );

    final firstDay = DateTime(year, month ?? 1, day ?? 1);
    final lastDay = day != null
        ? firstDay.add(Duration(days: 1)) // 日指定の場合は次の日
        : month != null
            ? DateTime(year, month + 1, 1) // 月指定の場合は次の月の1日
            : DateTime(year + 1, 1, 1); // 年指定の場合は次の年の1日

    try {
      final querySnapshot = await sharedNoteDocRef
          .collection('expenses')
          .where(
            'date',
            isGreaterThanOrEqualTo: firstDay,
            isLessThan: lastDay,
          )
          .get();

      return Right(querySnapshot.docs.map((doc) => doc.data()).toList());
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// 共有ノートの指定された月のすべての収入を取得する。
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての収入を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての収入を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての収入を取得します。
  Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchMonthlySharedIncomesFrom(
    DocumentReference<Map<String, dynamic>> sharedNoteDocRef,
    int year, [
    int? month,
    int? day,
  ]) async {
    assert(
      (month != null && day != null) || // 全部指定
          (month != null && day == null) || // yearとmonth指定
          (month == null && day == null), // yearのみ指定
      'monthとdayの組み合わせが不適切です',
    );

    final firstDay = DateTime(year, month ?? 1, day ?? 1);
    final lastDay = day != null
        ? firstDay.add(Duration(days: 1)) // 日指定の場合は次の日
        : month != null
            ? DateTime(year, month + 1, 1) // 月指定の場合は次の月の1日
            : DateTime(year + 1, 1, 1); // 年指定の場合は次の年の1日

    try {
      final querySnapshot = await sharedNoteDocRef
          .collection('incomes')
          .where(
            'date',
            isGreaterThanOrEqualTo: firstDay,
            isLessThan: lastDay,
          )
          .get();

      return Right(querySnapshot.docs.map((doc) => doc.data()).toList());
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // ============================================================================
  // 収入カテゴリ関連メソッド
  // ============================================================================

  /// [userId]のすべての収入カテゴリを取得する
  Future<Either<Exception, List<IncomeCategoryModel>>>
      fetchPersonalIncomeCategories(UserIdVo userId) async {
    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .get();

      final categories = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return IncomeCategoryModel.fromJson(data);
      }).toList(growable: false);

      return Right(categories);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に収入カテゴリを追加する
  Future<Either<Exception, Unit>> addPersonalIncomeCategory(
    UserIdVo userId,
    IncomeCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .doc(category.id)
          .set(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の収入カテゴリを更新する
  Future<Either<Exception, Unit>> updatePersonalIncomeCategory(
    UserIdVo userId,
    IncomeCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .doc(category.id)
          .update(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の収入カテゴリを削除する
  Future<Either<Exception, Unit>> deletePersonalIncomeCategory(
    UserIdVo userId,
    String categoryId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomeCategories')
          .doc(categoryId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // ============================================================================
  // 支出カテゴリ関連メソッド
  // ============================================================================

  /// [userId]のすべての支出カテゴリを取得する
  Future<Either<Exception, List<ExpenseCategoryModel>>>
      fetchPersonalExpenseCategories(UserIdVo userId) async {
    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .get();

      final categories = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return ExpenseCategoryModel.fromJson(data);
      }).toList(growable: false);

      return Right(categories);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に支出カテゴリを追加する
  Future<Either<Exception, Unit>> addPersonalExpenseCategory(
    UserIdVo userId,
    ExpenseCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .doc(category.id)
          .set(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の支出カテゴリを更新する
  Future<Either<Exception, Unit>> updatePersonalExpenseCategory(
    UserIdVo userId,
    ExpenseCategoryModel category,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .doc(category.id)
          .update(category.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の支出カテゴリを削除する
  Future<Either<Exception, Unit>> deletePersonalExpenseCategory(
    UserIdVo userId,
    String categoryId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenseCategories')
          .doc(categoryId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // ============================================================================
  // 資産関連メソッド
  // ============================================================================

  /// [userId]のすべての資産を取得する
  Future<Either<Exception, List<PropertyModel>>> fetchPersonalProperties(
      UserIdVo userId) async {
    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/properties')
          .get();

      final properties = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return PropertyModel.fromJson(data);
      }).toList(growable: false);

      return Right(properties);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に資産を追加する
  Future<Either<Exception, Unit>> addPersonalProperty(
    UserIdVo userId,
    PropertyModel property,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/properties')
          .doc(property.id)
          .set(property.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の資産を更新する
  Future<Either<Exception, Unit>> updatePersonalProperty(
    UserIdVo userId,
    PropertyModel property,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/properties')
          .doc(property.id)
          .update(property.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の資産を削除する
  Future<Either<Exception, Unit>> deletePersonalProperty(
    UserIdVo userId,
    String propertyId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/properties')
          .doc(propertyId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // ============================================================================
  // 支出レコード関連メソッド
  // ============================================================================

  /// [userId]の指定された日付範囲のすべての支出を取得する（V2データモデル）
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての支出を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての支出を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての支出を取得します。
  Future<Either<Exception, List<ExpenseRecordModel>>> fetchPersonalExpenses(
    UserIdVo userId,
    int year, [
    int? month,
    int? day,
  ]) async {
    assert(
      (month != null && day != null) || // 全部指定
          (month != null && day == null) || // yearとmonth指定
          (month == null && day == null), // yearのみ指定
      'monthとdayの組み合わせが不適切です',
    );

    final firstDay = DateTime(year, month ?? 1, day ?? 1);
    final lastDay = day != null
        ? firstDay.add(Duration(days: 1)) // 日指定の場合は次の日
        : month != null
            ? DateTime(year, month + 1, 1) // 月指定の場合は次の月の1日
            : DateTime(year + 1, 1, 1); // 年指定の場合は次の年の1日

    try {
      final snapshot = await _db
          .collection('/personalNotes/${userId.value}/expenses')
          .where(
            'date',
            isGreaterThanOrEqualTo: firstDay,
            isLessThan: lastDay,
          )
          .get();

      final expenses = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return ExpenseRecordModel.fromJson(data);
      }).toList(growable: false);

      return Right(expenses);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に支出レコードを追加する
  Future<Either<Exception, Unit>> addPersonalExpense(
    UserIdVo userId,
    ExpenseRecordModel expense,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenses')
          .doc(expense.id)
          .set(expense.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の支出レコードを削除する
  Future<Either<Exception, Unit>> deletePersonalExpense(
    UserIdVo userId,
    String expenseId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/expenses')
          .doc(expenseId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // ============================================================================
  // 収入レコード関連メソッド（追加機能）
  // ============================================================================

  /// [userId]の指定された日付範囲のすべての収入を取得する（V2データモデル）
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての収入を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての収入を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての収入を取得します。
  Future<Either<Exception, List<IncomeRecordModel>>> fetchPersonalIncomes(
    UserIdVo userId,
    int year, [
    int? month,
    int? day,
  ]) async {
    assert(
      (month != null && day != null) || // 全部指定
          (month != null && day == null) || // yearとmonth指定
          (month == null && day == null), // yearのみ指定
      'monthとdayの組み合わせが不適切です',
    );

    final firstDay = DateTime(year, month ?? 1, day ?? 1);
    final lastDay = day != null
        ? firstDay.add(Duration(days: 1)) // 日指定の場合は次の日
        : month != null
            ? DateTime(year, month + 1, 1) // 月指定の場合は次の月の1日
            : DateTime(year + 1, 1, 1); // 年指定の場合は次の年の1日

    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/incomes')
          .where(
            'date',
            isGreaterThanOrEqualTo: firstDay,
            isLessThan: lastDay,
          )
          .get();

      final incomes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return IncomeRecordModel.fromJson(data);
      }).toList(growable: false);

      return Right(incomes);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に収入レコードを追加する
  Future<Either<Exception, Unit>> addPersonalIncome(
    UserIdVo userId,
    IncomeRecordModel income,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomes')
          .doc(income.id)
          .set(income.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の収入レコードを削除する
  Future<Either<Exception, Unit>> deletePersonalIncome(
    UserIdVo userId,
    String incomeId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/incomes')
          .doc(incomeId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // ============================================================================
  // 振替レコード関連メソッド
  // ============================================================================

  /// [userId]の指定された日付範囲のすべての振替を取得する
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての振替を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての振替を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての振替を取得します。
  Future<Either<Exception, List<TransferRecordModel>>> fetchPersonalTransfers(
    UserIdVo userId,
    int year, [
    int? month,
    int? day,
  ]) async {
    assert(
      (month != null && day != null) || // 全部指定
          (month != null && day == null) || // yearとmonth指定
          (month == null && day == null), // yearのみ指定
      'monthとdayの組み合わせが不適切です',
    );

    final firstDay = DateTime(year, month ?? 1, day ?? 1);
    final lastDay = day != null
        ? firstDay.add(Duration(days: 1)) // 日指定の場合は次の日
        : month != null
            ? DateTime(year, month + 1, 1) // 月指定の場合は次の月の1日
            : DateTime(year + 1, 1, 1); // 年指定の場合は次の年の1日

    try {
      final querySnapshot = await _db
          .collection('/personalNotes/${userId.value}/transfers')
          .where(
            'date',
            isGreaterThanOrEqualTo: firstDay,
            isLessThan: lastDay,
          )
          .get();

      final transfers = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ドキュメントIDを追加
        return TransferRecordModel.fromJson(data);
      }).toList(growable: false);

      return Right(transfers);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]に振替レコードを追加する
  Future<Either<Exception, Unit>> addPersonalTransfer(
    UserIdVo userId,
    TransferRecordModel transfer,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/transfers')
          .doc(transfer.id)
          .set(transfer.toFirestoreJson());
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の振替レコードを削除する
  Future<Either<Exception, Unit>> deletePersonalTransfer(
    UserIdVo userId,
    String transferId,
  ) async {
    try {
      await _db
          .collection('/personalNotes/${userId.value}/transfers')
          .doc(transferId)
          .delete();
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // ============================================================================
  // Transaction処理メソッド
  // ============================================================================

  /// Firestoreトランザクションを実行する
  ///
  /// 複数のFirestore操作を原子的に実行する必要がある場合に使用する。
  /// 資産残高の更新と収入/支出/振替レコードの作成を同時に行う場合など。
  Future<Either<Exception, Unit>> executeTransaction(
    Future<void> Function(Transaction transaction) transactionHandler,
  ) async {
    try {
      await _db.runTransaction(transactionHandler);
      return Right(unit);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
