import 'package:flutter/material.dart';

import '../../widgets/error_message.dart';
import 'view_model.dart';
import 'widgets/user_name_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: _InitializationHandler(
        viewModel: _viewModel,
      ),
    );
  }
}

class _InitializationHandler extends StatelessWidget {
  const _InitializationHandler({
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

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

        return _SaveErrorHandler(
          viewModel: _viewModel,
        );
      },
    );
  }
}

class _SaveErrorHandler extends StatelessWidget {
  const _SaveErrorHandler({
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel.save,
      builder: (context, child) {
        if (_viewModel.save.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ユーザー名の保存に失敗しました'),
              ),
            );
            _viewModel.save.resetError();
          });
        }

        return child!;
      },
      child: _SettingsContent(
        viewModel: _viewModel,
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (_, __) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            UserNameCard(
              viewModel: _viewModel,
            ),
          ],
        ),
      ),
    );
  }
}
