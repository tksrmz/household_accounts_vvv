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
    required DateTime date,
    required UserIdVo userId,
  })  : _incomeRepository = incomeRepository,
        _expenseRepository = expenseRepository,
        _publicProfileRepository = publicProfileRepository,
        super(DashboardState.uninitialized(_emptyInfo)) {
    _initCommand = AsyncCommand2(_initializeData);
    _initCommand.call(date, userId);
  }

  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;
  final PublicProfileRepository _publicProfileRepository;

  /// 初期化コマンド
  late final AsyncCommand2<DateTime, UserIdVo> _initCommand;

  /// 初期化コマンドのgetter
  AsyncCommand2<DateTime, UserIdVo> get init => _initCommand;

  Future<void> _initializeData(DateTime date, UserIdVo userId) async {
    try {
      final incomeResult = await _incomeRepository.fetchMonthly(date);
      final List<IncomeVo> incomeList = incomeResult.fold(
        (exception) => throw exception,
        (incomes) => incomes,
      );
      final expenseResult = await _expenseRepository.fetchMonthly(date);
      final List<ExpenseVo> expenseList = expenseResult.fold(
        (exception) => throw exception,
        (expenses) => expenses,
      );
      final userNameResult = await _publicProfileRepository.fetchUserName(userId);
      final UserNameVo userName = userNameResult.fold(
        (exception) => throw exception,
        (name) => name,
      );

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
