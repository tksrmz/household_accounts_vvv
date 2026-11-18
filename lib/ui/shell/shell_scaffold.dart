import 'package:flutter/material.dart';

import 'shell_view_model.dart';
import 'widgets/shell_drawer.dart';

const _titles = ['ダッシュボード', '入力', 'カレンダー', '資産', 'カテゴリ', '予算'];

/// シェルの見た目そのもの。
///
/// ルーターに依存せず、タブ選択・設定遷移はコールバックで受け取る
/// (goldenテストの対象にするため)。
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    required this.currentIndex,
    required this.onSelectTab,
    required this.onOpenSettings,
    required this.viewModel,
    required this.body,
    super.key,
  });

  /// 選択中のタブのインデックス。
  final int currentIndex;

  /// タブが選択されたときに呼ばれる。
  final void Function(int) onSelectTab;

  /// 設定画面を開くときに呼ばれる。
  final VoidCallback onOpenSettings;

  /// ドロワーとログアウトの状態を提供するViewModel。
  final ShellViewModel viewModel;

  /// タブの中身。
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[currentIndex]),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => viewModel.logout.execute(),
              ),
            ],
          ),
          drawer: ShellDrawer(
            kind: viewModel.notebookKind,
            canSwitch: viewModel.canSwitchNote,
            onSwitchNotebook: viewModel.switchNotebook,
            onOpenSettings: onOpenSettings,
          ),
          body: body,
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.sunny),
                label: 'ダッシュボード',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.cloud), label: '入力'),
              BottomNavigationBarItem(
                icon: Icon(Icons.beach_access),
                label: 'カレンダー',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_alarm),
                label: '資産',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.accessibility),
                label: 'カテゴリ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.next_plan_outlined),
                label: '予算',
              ),
            ],
            currentIndex: currentIndex,
            onTap: onSelectTab,
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
