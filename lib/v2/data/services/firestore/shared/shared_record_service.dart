import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

/// 共有ノートのレコードに関するFirestore操作を提供するサービス
class SharedRecordService {
  const SharedRecordService();

  /// 共有ノートの指定された月のすべての支出を取得する。
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての支出を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての支出を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての支出を取得します。
  Future<Either<Exception, List<Map<String, dynamic>>>> fetchExpensesByDate(
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
  Future<Either<Exception, List<Map<String, dynamic>>>> fetchIncomesByDate(
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
}
