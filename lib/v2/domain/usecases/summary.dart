import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../entity/expense.dart';
import '../../../entity/income.dart';
import '../repositories/expense_repository.dart';
import '../repositories/income_repository.dart';

part 'summary.freezed.dart';

class SummaryUseCase {
  const SummaryUseCase({
    required this.incomeRepository,
    required this.expenseRepository,
  });

  final IncomeRepository incomeRepository;
  final ExpenseRepository expenseRepository;

  /// 当該月の収支データを取得する
  ///
  /// 例外が発生した場合は[SummaryModelException]をスローする
  ///
  /// [date] 取得対象の年月
  Future<Summary> fetch(DateTime date) async {
    final incomeList = await _fetchIterableOfIntFromThrowableSupplier(
      () async =>
          (await incomeRepository.fetchMonthly(date)).map((e) => e.value),
      'IncomeRepositoryでエラーが発生しました',
    );

    final expenseList = await _fetchIterableOfIntFromThrowableSupplier(
      () async =>
          (await expenseRepository.fetchMonthly(date)).map((e) => e.value),
      'ExpenseRepositoryでエラーが発生しました',
    );

    return Summary(
      Income(_sumOf(incomeList)),
      Expense(_sumOf(expenseList)),
    );
  }

  int _sumOf(Iterable<int> iterable) {
    return iterable.fold<int>(0, (prev, element) => prev + element);
  }

  Future<Iterable<int>> _fetchIterableOfIntFromThrowableSupplier(
    Future<Iterable<int>> Function() supplier,
    String errorMessage,
  ) async {
    try {
      return await supplier();
    } on Exception {
      throw SummaryModelException(errorMessage);
    }
  }
}

@freezed
class Summary with _$Summary {
  const factory Summary(Income income, Expense expense) = _Summary;
}

/// SummaryModelでエラーが発生したときにスローされる例外
@freezed
class SummaryModelException with _$SummaryModelException implements Exception {
  @Assert('message.length > 0', 'エラーメッセージが空です')
  const factory SummaryModelException(String message) = _SummaryModelException;
}
