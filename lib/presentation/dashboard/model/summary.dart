import '../../../entity/expense.dart';
import '../../../entity/income.dart';

class SummaryModel {
  /// 当該月の収支データを取得する
  Future<Summary> fetch() async {
    throw UnimplementedError();
  }
}

class Summary {
  const Summary(this.income, this.expense);

  final Income income;
  final Expense expense;
}
