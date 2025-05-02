import 'package:flutter/material.dart';

import '../../../../presentation/dashboard/widget/error_message.dart';
import '../../../../presentation/dashboard/widget/summary_panel.dart';
import 'view_model.dart';

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
          return ErrorMessage();
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
