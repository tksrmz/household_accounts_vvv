import 'package:flutter/material.dart';

import '../../core/selected_notebook.dart';

/// シェルのドロワー。ノート切替と設定画面への導線を持つ。
///
/// ルーターへ直接依存させないため、遷移はすべてコールバックで受け取る
/// (goldenテストからrouter無しで組み立てられるようにするため)。
class ShellDrawer extends StatelessWidget {
  const ShellDrawer({
    required this.kind,
    required this.canSwitch,
    required this.onSwitchNotebook,
    required this.onOpenSettings,
    super.key,
  });

  /// 現在選択されているノート。
  final NotebookKind kind;

  /// ノート切替タイルを表示するかどうか(= ペアが存在するかどうか)。
  final bool canSwitch;

  /// ノート切替が要求されたときに呼ばれる。
  final void Function(NotebookKind) onSwitchNotebook;

  /// 設定画面を開くときに呼ばれる。
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _getIcon(),
                ),
                Text(
                  _getHeaderTitle(),
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          if (canSwitch) _getListTile(context),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            // 旧実装どおり、設定を開く前にドロワーを閉じない
            onTap: onOpenSettings,
          ),
        ],
      ),
    );
  }

  String _getHeaderTitle() {
    final String modeText;

    switch (kind) {
      case NotebookKind.personal:
        modeText = '自分の家計簿';
        break;

      case NotebookKind.shared:
        modeText = 'ふたりの家計簿';
        break;
    }

    return modeText;
  }

  ListTile _getListTile(BuildContext context) {
    final Text title;
    final void Function() onTap;

    switch (kind) {
      case NotebookKind.personal:
        title = Text('ふたりの家計簿を見る');
        onTap = () {
          onSwitchNotebook(NotebookKind.shared);
          Navigator.pop(context); // close the drawer
        };
        break;

      case NotebookKind.shared:
        title = Text('自分の家計簿を見る');
        onTap = () {
          onSwitchNotebook(NotebookKind.personal);
          Navigator.pop(context); // close the drawer
        };
        break;
    }

    return ListTile(
      leading: const Icon(Icons.swap_horiz),
      title: title,
      onTap: onTap,
    );
  }

  Icon _getIcon() {
    final Icon icon;

    switch (kind) {
      case NotebookKind.personal:
        icon = const Icon(Icons.person, color: Colors.white);
        break;

      case NotebookKind.shared:
        icon = const Icon(Icons.group, color: Colors.white);
        break;
    }

    return icon;
  }
}
