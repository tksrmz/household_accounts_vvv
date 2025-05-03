import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:household_accounts/v2/domain/models/dashboard_info.dart';
import 'package:household_accounts/v2/domain/models/vo/user_name.dart';

import '../models/vo/expense.dart';
import '../models/vo/income.dart';
import '../models/vo/user_id.dart';
import '../repositories/expense_repository.dart';
import '../repositories/income_repository.dart';
import '../repositories/public_profile_repository.dart';

part 'dashboard.freezed.dart';

class DashboardUseCase {
  const DashboardUseCase({
    required this.incomeRepository,
    required this.expenseRepository,
    this.publicProfileRepository,
  });

  final IncomeRepository incomeRepository;
  final ExpenseRepository expenseRepository;
  final PublicProfileRepository? publicProfileRepository;

  /// 当該月の収支データを取得する
  ///
  /// 例外が発生した場合は[DashboardUseCaseException]をスローする
  ///
  /// [date] 取得対象の年月
  /// [userId] ユーザー名を取得するアカウントのユーザID
  Future<DashboardInfoModel> fetch(
    DateTime date, [
    UserIdVo userId = const UserIdVo("hoge"),
  ]) async {
    //   DateTime date,
    // ) async {
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

    final UserNameVo? userName;
    try {
      userName = await publicProfileRepository?.fetchUserName(userId);
    } on Exception {
      throw DashboardUseCaseException('PublicProfileRepositoryでエラーが発生しました');
    }

    // return DashboardInfoModel(
    //   IncomeVo(_sumOf(incomeList)),
    //   ExpenseVo(_sumOf(expenseList)),
    // );
    return userName == null
        ? DashboardInfoModel(
            IncomeVo(_sumOf(incomeList)),
            ExpenseVo(_sumOf(expenseList)),
          )
        : DashboardInfoModel(
            IncomeVo(_sumOf(incomeList)),
            ExpenseVo(_sumOf(expenseList)),
            userName,
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
