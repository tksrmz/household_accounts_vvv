import '../../../entity/income.dart';

abstract interface class IncomeRepository {
  /// 指定された年月の収入データを取得する
  Future<List<Income>> fetchMonthly(DateTime date);
}
