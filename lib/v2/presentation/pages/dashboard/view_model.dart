import 'package:flutter/foundation.dart';

import '../../../domain/models/dashboard_info.dart';
import '../../../domain/models/vo/user_id.dart';
import '../../../domain/usecases/dashboard.dart';
import 'state.dart';

/// ダッシュボードを表示するためのViewModel
class DashboardViewModel extends ValueNotifier<DashboardState> {
  DashboardViewModel({
    required DashboardUseCase dashboardUseCase,
  })  : _dashboardUseCase = dashboardUseCase,
        super(DashboardState.uninitialized());

  final DashboardUseCase _dashboardUseCase;

  Future<void> init(DateTime date) async {
    if (!value.isUninitialized) {
      return;
    }

    try {
      DashboardInfoModel info = await _dashboardUseCase.fetch(
        date,
        UserIdVo("hoge"),
      );
      value = value.success(info);
    } on DashboardUseCaseException catch (ex) {
      print(ex);
      value = value.fail();
    }
  }
}
