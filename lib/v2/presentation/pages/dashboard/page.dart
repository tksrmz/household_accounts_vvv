import 'package:flutter/material.dart';

import '../../../domain/models/vo/user_id.dart';
import 'view_model.dart';
import 'widgets/error_message.dart';
import 'widgets/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({
    super.key,
    required DateTime date,
    required UserIdVo userId,
    required this.viewModel,
  }) {
    viewModel.init(date, userId);
  }

  final DashboardViewModel viewModel;

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
              Text('${state.userName.value}の家計簿'),
              const SizedBox(height: 16),
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
