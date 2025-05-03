import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/summary.dart';
import '../models/vo/expense.dart';
import '../models/vo/income.dart';
import '../repositories/expense_repository.dart';
import '../repositories/income_repository.dart';

part 'dashboard.freezed.dart';

class DashboardUseCase {
  const DashboardUseCase({
    required this.incomeRepository,
    required this.expenseRepository,
  });

  final IncomeRepository incomeRepository;
  final ExpenseRepository expenseRepository;

  /// 当該月の収支データを取得する
  ///
  /// 例外が発生した場合は[DashboardUseCaseException]をスローする
  ///
  /// [date] 取得対象の年月
  Future<SummaryModel> fetch(DateTime date) async {
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

    return SummaryModel(
      IncomeVo(_sumOf(incomeList)),
      ExpenseVo(_sumOf(expenseList)),
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
      throw DashboardUseCaseException(errorMessage);
    }
  }
}

/// [DashboardUseCase]でエラーが発生したときにスローされる例外
@freezed
abstract class DashboardUseCaseException
    with _$DashboardUseCaseException
    implements Exception {
  const factory DashboardUseCaseException(String message) =
      _DashboardUseCaseException;
}
