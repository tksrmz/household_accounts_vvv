import 'package:dartz/dartz.dart';

import '../models/vo/income.dart';
import '../models/income_record.dart';
import '../models/vo/record_id.dart';

abstract interface class IncomeRepository {
  /// 指定された年月の収入データを取得する
  ///
  /// [date]で指定された年月以外の情報は無視される。
  /// つまり、[date]として2025/1/2 12:34:56を指定した場合と2025/1/1 00:00:00を指定した場合は同じ結果が返される。
  ///
  /// 返却されるListの順番については保証されない。
  ///
  /// [date] 取得対象の年月
  Future<Either<Exception, List<IncomeVo>>> fetchMonthly(DateTime date);

  /// 収入レコードを追加する
  ///
  /// [record] 追加する収入レコード
  Future<Either<Exception, Unit>> add(IncomeRecordVo record);

  /// 収入レコードを削除する
  ///
  /// [id] 削除対象のレコードID
  Future<Either<Exception, Unit>> delete(RecordIdVo id);
}
