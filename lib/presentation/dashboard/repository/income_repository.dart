import '../../../entity/income.dart';

abstract interface class IncomeRepository {
  /// 指定された年月の収入データを取得する
  ///
  /// [date]で指定された年月以外の情報は無視される。
  /// つまり、[date]として2025/1/2 12:34:56を指定した場合と2025/1/1 00:00:00を指定した場合は同じ結果が返される。
  ///
  /// 返却されるListの順番については保証されない。
  ///
  /// [date] 取得対象の年月
  Future<List<Income>> fetchMonthly(DateTime date);
}
