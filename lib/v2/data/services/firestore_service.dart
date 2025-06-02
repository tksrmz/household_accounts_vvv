import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/privateProfile.dart';

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
  Future<Either<Exception, List<Map<String, dynamic>>>>
      fetchAllPersonalExpensesOf(
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

      return Right(snapshot.docs.map((doc) => doc.data()).toList());
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]の指定された月のすべての収入を取得する。
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての収入を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての収入を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての収入を取得します。
  Future<Either<Exception, List<Map<String, dynamic>>>> fetchMonthlyPersonalIncomesOf(
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

      return Right(querySnapshot.docs.map((doc) => doc.data()).toList());
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// [userId]のユーザー名を取得する。
  Future<Either<Exception, Map<String, dynamic>>> fetchPublicProfileOf(UserIdVo userId) async {
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
  Future<Either<Exception, DocumentSnapshot<PrivateProfile>>> fetchPrivateProfileOf(
    UserIdVo userId,
  ) async {
    try {
      final documentSnapshot = await _db
          .doc('/privateProfiles/${userId.value}')
          .withConverter(
            fromFirestore: (snapshot, _) =>
                PrivateProfile.fromJson(snapshot.data()!),
            toFirestore: (data, _) => data.toJson(),
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
  Future<Either<Exception, List<Map<String, dynamic>>>> fetchMonthlySharedExpensesFrom(
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
  Future<Either<Exception, List<Map<String, dynamic>>>> fetchMonthlySharedIncomesFrom(
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
