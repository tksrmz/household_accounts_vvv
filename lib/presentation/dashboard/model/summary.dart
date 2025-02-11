import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../entity/expense.dart';
import '../../../entity/income.dart';
import '../repository/expense_repository.dart';
import '../repository/income_repository.dart';

part 'summary.freezed.dart';

class SummaryModel {
  const SummaryModel({
    required this.incomeRepository,
    required this.expenseRepository,
  });

  final IncomeRepository incomeRepository;
  final ExpenseRepository expenseRepository;

  /// 当該月の収支データを取得する
  ///
  /// エラーが発生した場合は[SummaryModelException]をスローする
  ///
  /// [date] 取得対象の年月
  Future<Summary> fetch(DateTime date) async {
    final incomeList = await incomeRepository.fetchMonthly(date);
    final expenseList = await expenseRepository.fetchMonthly(date);

    return Summary(
      Income(
        incomeList.fold<int>(0, (prev, element) => prev + element.value),
      ),
      Expense(
        expenseList.fold<int>(0, (prev, element) => prev + element.value),
      ),
    );
  }
}

class Summary {
  const Summary(this.income, this.expense);

  final Income income;
  final Expense expense;
}

/// SummaryModelでエラーが発生したときにスローされる例外
@freezed
class SummaryModelException with _$SummaryModelException implements Exception {
  @Assert('message.length > 0', 'エラーメッセージが空です')
  const factory SummaryModelException(String message) = _SummaryModelException;
}
