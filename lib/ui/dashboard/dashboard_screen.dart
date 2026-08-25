import 'package:flutter/material.dart';

import '../../domain/models/record_summary.dart';
import '../../domain/models/user_name.dart';
import 'dashboard_view_model.dart';
import 'widgets/summary_panel.dart';

/// ダッシュボード画面。
///
/// シェル(タブ)の本体として表示されるため、Scaffoldは持たない。
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required DashboardViewModel viewModel})
    : _viewModel = viewModel;

  final DashboardViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      // ユーザー名(読み込みコマンド)とレコード(購読結果を持つViewModel)は
      // 別々に届くため、どちらの変化でも描画し直せるよう両方を購読する
      listenable: Listenable.merge([_viewModel, _viewModel.load]),
      builder: (context, _) {
        if (_viewModel.load.error || _viewModel.recordsError != null) {
          return const Center(child: _ErrorMessage());
        }

        final userName = _viewModel.userName;
        final summary = _viewModel.summary;
        // ユーザー名とレコードのどちらかが未着の間はローディングとして扱う
        // (片方だけの表示は中途半端な画面になるため)
        if (userName == null || summary == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _DashboardContent(
          userName: userName,
          summary: summary,
          isPersonal: _viewModel.isPersonal,
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.userName,
    required this.summary,
    required this.isPersonal,
  });

  final UserName userName;
  final RecordSummary summary;
  final bool isPersonal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          Center(
            child: Text(
              '${userName.value}の${isPersonal ? '自分' : 'ふたり'}の家計簿',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SummaryPanel(summary: summary),
        ],
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
