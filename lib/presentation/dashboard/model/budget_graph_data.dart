import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../vo/budget_amount.dart';
import '../../../vo/budget_spent.dart';
import '../vo/budget_name.dart';

part 'budget_graph_data.freezed.dart';

@freezed
class BudgetGraphData with _$BudgetGraphData {
  const factory BudgetGraphData({
    required BudgetName name,
    required BudgetSpent spent,
    required BudgetAmount budget,
  }) = _BudgetGraphData;
}
