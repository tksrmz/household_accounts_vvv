import 'package:flutter/material.dart';

import 'view_model.dart';
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
        if (viewModel.isBeforeInitialization) {
          return CircularProgressIndicator();
        }
        if (viewModel.hasError) {
          return Text(viewModel.errorMessage);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              SummaryPanel(
                viewModel.income!,
                viewModel.expense!,
              ),
              // out of scope for this sprint
              // SizedBox(height: 16.0),
              // BudgetGraph(
              //   list: viewModel.budgetGraphDataList!,
              // ),
            ],
          ),
        );
      },
    );
  }
}
