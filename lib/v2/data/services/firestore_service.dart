import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/vo/user_id.dart';
import '../../domain/models/vo/user_name.dart';

/// Firestoreと連携するためのサービス
class FirestoreService {
  final FirebaseFirestore _db;

  const FirestoreService(this._db);

  /// [userId]の指定された日付範囲のすべての支出を取得する。
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての支出を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての支出を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての支出を取得します。
  Future<List<Map<String, dynamic>>> fetchAllPersonalExpensesOf(
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

    final snapshot = await _db
        .collection('/personalNotes/${userId.value}/expenses')
        .where(
          'date',
          isGreaterThanOrEqualTo: firstDay,
          isLessThan: lastDay,
        )
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// [userId]の指定された月のすべての収入を取得する。
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての収入を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての収入を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての収入を取得します。
  Future<List<Map<String, dynamic>>> fetchMonthlyPersonalIncomesOf(
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

    final querySnapshot = await _db
        .collection('/personalNotes/${userId.value}/incomes')
        .where(
          'date',
          isGreaterThanOrEqualTo: firstDay,
          isLessThan: lastDay,
        )
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// [userId]のユーザー名を取得する。
  Future<Map<String, dynamic>> fetchPublicProfileOf(UserIdVo userId) async {
    final documentReference = _db.doc('/publicProfiles/${userId.value}');
    final documentSnapshot = await documentReference.get();
    return documentSnapshot.data()!;
  }

  /// [userId]のユーザー名を更新する。
  Future<void> updatePublicProfileNameOf(
    UserIdVo userId,
    UserNameVo userName,
  ) async {
    final documentReference = _db.doc('/publicProfiles/${userId.value}');
    await documentReference.update({
      'name': userName.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
