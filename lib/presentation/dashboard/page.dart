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

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        if (viewModel.isNotInitialized) {
          return CircularProgressIndicator();
        }
        if (viewModel.hasError) {
          return Text(viewModel.errorMessage);
        }

        return Column(
          spacing: 16,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SummaryPanel(
                      viewModel.income!,
                      viewModel.expense!,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: BudgetGraph(
                      list: viewModel.budgetGraphDataList!,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
