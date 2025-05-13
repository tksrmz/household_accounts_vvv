import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/user_auth.dart';
import '../state_managements/selected_note_state.dart';
import 'view_model.dart';
import '../../widgets/error_message.dart';
import 'widgets/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({
    super.key,
    required DateTime date,
    required DashboardViewModel viewModel,
  })  : _date = date,
        _viewModel = viewModel;

  final DashboardViewModel _viewModel;
  final DateTime _date;

  @override
  Widget build(BuildContext context) {
    _viewModel.init(_date, context.read<UserAuth>().uid);

    return ValueListenableBuilder(
      valueListenable: _viewModel,
      builder: (context, state, child) {
        if (state.isUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.isFailed) {
          return ErrorMessage();
        }

        bool isPersonal = context.watch<SelectedNoteState>().isPersonal;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              Center(
                child: Text(
                  '${state.model.userName.value}の${isPersonal ? '自分' : 'ふたり'}の家計簿',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              SummaryPanel(
                state.model.income,
                state.model.expense,
              ),
            ],
          ),
        );
      },
    );
  }
}
