import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/expense_record_model.dart';

import '../../../../domain/models/vo/user_id.dart';

/// 個人の支出レコードに関するFirestore操作を提供するサービス
class PersonalExpenseRecordService {
  final FirebaseFirestore _db;

  const PersonalExpenseRecordService(this._db);

  /// [userId]の指定された日付範囲のすべての支出を取得する（V2データモデル）
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての支出を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての支出を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての支出を取得します。
  Future<Either<Exception, List<ExpenseRecordModel>>> fetchByDate(
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
  Future<Either<Exception, Unit>> add(
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
  Future<Either<Exception, Unit>> delete(
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
}
