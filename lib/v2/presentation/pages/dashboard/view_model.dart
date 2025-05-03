import 'package:flutter/foundation.dart';

import '../../../domain/models/summary.dart';
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
      SummaryModel summary = await _dashboardUseCase.fetch(date);
      value = value.success(summary.income, summary.expense);
    } on DashboardUseCaseException catch (ex) {
      print(ex);
      value = value.fail();
    }
  }
}
