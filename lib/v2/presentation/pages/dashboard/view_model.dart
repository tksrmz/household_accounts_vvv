import 'package:flutter/foundation.dart';

import '../../../domain/models/dashboard_info.dart';
import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/income.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/income_repository.dart';
import '../../../domain/repositories/public_profile_repository.dart';
import '../../commands/command.dart';
import '../state_managements/initializable_state.dart';

/// ダッシュボードを表示するためのViewModel
class DashboardViewModel extends ValueNotifier<DashboardState> {
  static const DashboardInfoModel _emptyInfo = DashboardInfoModel(
    IncomeVo.empty,
    ExpenseVo.empty,
    UserNameVo.empty,
  );

  DashboardViewModel({
    required IncomeRepository incomeRepository,
    required ExpenseRepository expenseRepository,
    required PublicProfileRepository publicProfileRepository,
  })  : _incomeRepository = incomeRepository,
        _expenseRepository = expenseRepository,
        _publicProfileRepository = publicProfileRepository,
        super(DashboardState.uninitialized(_emptyInfo)) {
    _initCommand = AsyncCommand2(_initializeData);
  }

  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;
  final PublicProfileRepository _publicProfileRepository;

  /// 初期化コマンド
  late final AsyncCommand2<DateTime, UserIdVo> _initCommand;

  /// 初期化コマンドのgetter
  AsyncCommand2<DateTime, UserIdVo> get initCommand => _initCommand;

  Future<void> init(
    DateTime date,
    UserIdVo userId,
  ) async {
    if (!value.isUninitialized) {
      return;
    }

    await _initCommand.call(date, userId);
  }

  Future<void> _initializeData(DateTime date, UserIdVo userId) async {
    try {
      final List<IncomeVo> incomeList =
          await _incomeRepository.fetchMonthly(date);
      final List<ExpenseVo> expenseList =
          await _expenseRepository.fetchMonthly(date);
      final UserNameVo userName =
          await _publicProfileRepository.fetchUserName(userId);

      final totalIncome = IncomeVo(_sumOf(incomeList.map((e) => e.value)));
      final totalExpense = ExpenseVo(_sumOf(expenseList.map((e) => e.value)));

      final info = DashboardInfoModel(totalIncome, totalExpense, userName);
      value = value.success(info);
    } catch (ex) {
      value = value.fail(_emptyInfo);
    }
  }

  int _sumOf(Iterable<int> iterable) {
    return iterable.fold<int>(0, (prev, element) => prev + element);
  }
}

/// ダッシュボードの状態を表すクラス
typedef DashboardState = InitializableState<DashboardInfoModel>;
