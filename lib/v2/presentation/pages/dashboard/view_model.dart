import 'package:flutter/foundation.dart';

import '../../../domain/models/dashboard_info.dart';
import '../../../domain/models/vo/expense.dart';
import '../../../domain/models/vo/income.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/models/vo/user_name.dart';
import '../../../domain/usecases/dashboard.dart';
import 'state.dart';

/// ダッシュボードを表示するためのViewModel
class DashboardViewModel extends ValueNotifier<DashboardState> {
  static const DashboardInfoModel _emptyInfo = DashboardInfoModel(
    IncomeVo.empty,
    ExpenseVo.empty,
    UserNameVo.empty,
  );

  DashboardViewModel({
    required DashboardUseCase dashboardUseCase,
  })  : _dashboardUseCase = dashboardUseCase,
        super(DashboardState.uninitialized(_emptyInfo));

  final DashboardUseCase _dashboardUseCase;

  Future<void> init(
    DateTime date,
    UserIdVo userId,
  ) async {
    if (!value.isUninitialized) {
      return;
    }

    try {
      DashboardInfoModel info = await _dashboardUseCase.fetch(date, userId);
      value = value.success(info);
    } on DashboardUseCaseException catch (ex) {
      print(ex);
      value = value.fail(_emptyInfo);
    }
  }
}
