import 'package:flutter/material.dart';

import 'view_model.dart';
import 'widget/budget_graph.dart';
import 'widget/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.viewModel});

  final SummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel.init();
    return viewModel.isNotInitialized
        ? CircularProgressIndicator()
        : Column(
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
