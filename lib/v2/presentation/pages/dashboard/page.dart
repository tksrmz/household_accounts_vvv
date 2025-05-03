import 'package:flutter/material.dart';

import 'view_model.dart';
import 'widgets/error_message.dart';
import 'widgets/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({
    super.key,
    required this.date,
    required this.viewModel,
  }) {
    viewModel.init(date);
  }

  final DateTime date;
  final SummaryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel,
      builder: (context, state, child) {
        if (state.isUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.isFailed) {
          return ErrorMessage();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              SummaryPanel(
                state.income,
                state.expense,
              ),
            ],
          ),
        );
      },
    );
  }
}
