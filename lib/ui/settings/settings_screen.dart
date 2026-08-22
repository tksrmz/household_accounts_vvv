import 'package:flutter/material.dart';

import 'settings_view_model.dart';
import 'widgets/user_name_card.dart';

/// 設定画面。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required SettingsViewModel viewModel})
    : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: _LoadHandler(viewModel: _viewModel),
    );
  }
}

/// 読み込みの実行状態に応じて、ローディング・エラー・コンテンツを出し分ける。
class _LoadHandler extends StatelessWidget {
  const _LoadHandler({required SettingsViewModel viewModel})
    : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel.load,
      builder: (context, child) {
        if (_viewModel.load.running) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_viewModel.load.error) {
          return const Center(child: _ErrorMessage());
        }

        return _SaveErrorHandler(viewModel: _viewModel);
      },
    );
  }
}

/// 保存の失敗をスナックバーで伝える。
class _SaveErrorHandler extends StatelessWidget {
  const _SaveErrorHandler({required SettingsViewModel viewModel})
    : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel.saveUserName,
      builder: (context, child) {
        if (_viewModel.saveUserName.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('ユーザー名の保存に失敗しました')));
            // 表示済みのエラーを消し、次の失敗でも再びスナックバーが出るようにする
            _viewModel.saveUserName.clearResult();
          });
        }

        // コンテンツは保存状態に依存しないため、childとして再ビルドを避ける
        return child!;
      },
      child: _SettingsContent(viewModel: _viewModel),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required SettingsViewModel viewModel})
    : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (_, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [UserNameCard(viewModel: _viewModel)]),
      ),
    );
  }
}

/// 読み込みに失敗したことを伝える表示。
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16.0),
          const Text('エラーが発生しました。'),
          const SizedBox(height: 8.0),
          const Text('アプリを再起動してください。'),
        ],
      ),
    );
  }
}
