import 'package:flutter/material.dart';

import 'view_model.dart';
import 'widget/budget_graph.dart';
import 'widget/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.date, required this.viewModel});

  final DateTime date;
  final SummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel.init(date);
    if (viewModel.isNotInitialized) {
      return CircularProgressIndicator();
    }
    if (viewModel.hasError) {
      return Text(viewModel.errorMessage);
    }
    return Column(
      children: [
        SummaryPanel(
          viewModel.income!,
          viewModel.expense!,
        ),
        BudgetGraph(
          list: viewModel.budgetGraphDataList!,
        )
      ],
    );
  }
}
