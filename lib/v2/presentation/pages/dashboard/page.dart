import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state_managements/selected_note_state.dart';
import 'view_model.dart';
import '../../widgets/error_message.dart';
import 'widgets/summary_panel.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({
    super.key,
    required DashboardViewModel viewModel,
  }) : _viewModel = viewModel;

  final DashboardViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return _InitializationHandler(
      viewModel: _viewModel,
    );
  }
}

class _InitializationHandler extends StatelessWidget {
  const _InitializationHandler({
    required DashboardViewModel viewModel,
  }) : _viewModel = viewModel;

  final DashboardViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel.init,
      builder: (context, child) {
        if (_viewModel.init.isExecuting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (_viewModel.init.hasError) {
          return const Center(
            child: ErrorMessage(),
          );
        }

        return _DashboardContent(
          viewModel: _viewModel,
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required DashboardViewModel viewModel,
  }) : _viewModel = viewModel;

  final DashboardViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _viewModel,
      builder: (context, state, child) {
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
