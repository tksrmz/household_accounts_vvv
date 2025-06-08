import 'package:dartz/dartz.dart';

import '../models/vo/expense.dart';
import '../models/expense_record.dart';
import '../models/vo/record_id.dart';

abstract interface class ExpenseRepository {
  /// 指定された年月の支出データを取得する
  ///
  /// [date]で指定された年月以外の情報は無視される。
  /// つまり、[date]として2025/1/2 12:34:56を指定した場合と2025/1/1 00:00:00を指定した場合は同じ結果が返される。
  ///
  /// 返却されるListの順番については保証されない。
  ///
  /// [date] 取得対象の年月
  Future<Either<Exception, List<ExpenseVo>>> fetchMonthly(DateTime date);

  /// 支出レコードを追加する
  ///
  /// [record] 追加する支出レコード
  Future<Either<Exception, Unit>> add(ExpenseRecordModel record);

  /// 支出レコードを削除する
  ///
  /// [id] 削除対象のレコードID
  Future<Either<Exception, Unit>> delete(RecordIdVo id);
}
