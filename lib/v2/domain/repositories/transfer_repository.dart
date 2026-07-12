import 'package:dartz/dartz.dart';

import '../models/transfer_record.dart';
import '../models/vo/record_id.dart';

/// 振替レコードのリポジトリインターフェース
abstract interface class TransferRepository {
  /// 指定された年月の振替データを取得する
  ///
  /// [date]で指定された年月以外の情報は無視される。
  /// つまり、[date]として2025/1/2 12:34:56を指定した場合と2025/1/1 00:00:00を指定した場合は同じ結果が返される。
  ///
  /// 返却されるListの順番については保証されない。
  ///
  /// [date] 取得対象の年月
  Future<Either<Exception, List<TransferRecordModel>>> fetchMonthly(
      DateTime date);

  /// 振替レコードを追加する
  ///
  /// [record] 追加する振替レコード
  Future<Either<Exception, Unit>> add(TransferRecordModel record);

  /// 振替レコードを削除する
  ///
  /// [id] 削除対象のレコードID
  Future<Either<Exception, Unit>> delete(RecordIdVo id);
}
