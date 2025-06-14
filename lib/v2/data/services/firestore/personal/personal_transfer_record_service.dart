import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/models/transfer_record_model.dart';

import '../../../../domain/models/vo/user_id.dart';

/// 個人の振替レコードに関するFirestore操作を提供するサービス
class PersonalTransferRecordService {
  final FirebaseFirestore _db;

  const PersonalTransferRecordService(this._db);

  /// [userId]の指定された日付範囲のすべての振替を取得する
  ///
  /// [year]は必須のパラメータです。
  /// [year]のみが指定されている場合、その年のすべての振替を取得します。
  /// [year]と[month]が指定されている場合、その月のすべての振替を取得します。
  /// [year]と[month]と[day]が指定されている場合、その日のすべての振替を取得します。
  Future<Either<Exception, List<TransferRecordModel>>> fetchByDate(
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
  Future<Either<Exception, Unit>> add(
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
  Future<Either<Exception, Unit>> delete(
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
}