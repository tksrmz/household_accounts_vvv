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
    required IncomeRepository incomeRepository,
    required ExpenseRepository expenseRepository,
    required PublicProfileRepository publicProfileRepository,
  })  : _incomeRepository = incomeRepository,
        _expenseRepository = expenseRepository,
        _publicProfileRepository = publicProfileRepository;

  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;
  final PublicProfileRepository _publicProfileRepository;

  /// 当該月の収支データを取得する
  ///
  /// 例外が発生した場合は[DashboardUseCaseException]をスローする
  ///
  /// [date] 取得対象の年月
  /// [userId] ユーザー名を取得するアカウントのユーザID
  Future<DashboardInfoModel> fetch(
    DateTime date,
    UserIdVo userId,
  ) async {
    final List<IncomeVo> incomeList;
    try {
      incomeList = await _incomeRepository.fetchMonthly(date);
    } on Exception {
      throw DashboardUseCaseException('IncomeRepositoryでエラーが発生しました');
    }

    final List<ExpenseVo> expenseList;
    try {
      expenseList = await _expenseRepository.fetchMonthly(date);
    } on Exception {
      throw DashboardUseCaseException('ExpenseRepositoryでエラーが発生しました');
    }

    final UserNameVo userName;
    try {
      userName = await _publicProfileRepository.fetchUserName(userId);
    } on Exception {
      throw DashboardUseCaseException('PublicProfileRepositoryでエラーが発生しました');
    }

    return DashboardInfoModel(
      IncomeVo(_sumOf(incomeList.map((e) => e.value))),
      ExpenseVo(_sumOf(expenseList.map((e) => e.value))),
      userName,
    );
  }

  int _sumOf(Iterable<int> iterable) {
    return iterable.fold<int>(0, (prev, element) => prev + element);
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
