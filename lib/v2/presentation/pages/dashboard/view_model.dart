import 'package:flutter/foundation.dart';

import '../../../domain/models/summary.dart';
import '../../../domain/usecases/summary.dart';
import 'state.dart';

/// ダッシュボードのサマリを表示するためのViewModel
class SummaryViewModel extends ValueNotifier<SummaryState> {
  SummaryViewModel({
    required this.summaryUseCase,
  }) : super(SummaryState.uninitialized());

  final SummaryUseCase summaryUseCase;

  Future<void> init(DateTime date) async {
    if (!value.isUninitialized) {
      return;
    }

    try {
      SummaryModel summary = await summaryUseCase.fetch(date);
      value = value.success(summary.income, summary.expense);
    } on SummaryUseCaseException catch (ex) {
      print(ex);
      value = value.fail();
    }
  }
}
