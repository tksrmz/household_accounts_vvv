import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../v2/domain/models/vo/user_id.dart';
import '../../v2/presentation/pages/settings/page.dart';
import '../../v2/presentation/pages/settings/view_model.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';

class MainPageDrawer extends StatelessWidget {
  const MainPageDrawer({
    required this.mode,
    required this.userId,
    this.setter,
    Key? key,
  }) : super(key: key);

  final SelectedNote mode;
  final UserIdVo userId;
  final void Function(SelectedNote)? setter;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _getIcon(),
                ),
                Text(
                  _getHeaderTitle(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          if (setter != null) _getListTile(context, setter!),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    userId: userId,
                    viewModel: SettingsViewModel(
                      publicProfileRepository: context.read(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getHeaderTitle() {
    final modeText;

    switch (mode) {
      case SelectedNote.personal:
        modeText = '自分の家計簿';
        break;

      case SelectedNote.shared:
        modeText = 'ふたりの家計簿';
        break;
    }

    return modeText;
  }

  ListTile _getListTile(
    BuildContext context,
    void Function(SelectedNote) setter,
  ) {
    final Text title;
    final void Function() onTap;

    switch (mode) {
      case SelectedNote.personal:
        title = Text('ふたりの家計簿を見る');
        onTap = () {
          setter(SelectedNote.shared);
          Navigator.pop(context); // close the drawer
        };
        break;

      case SelectedNote.shared:
        title = Text('自分の家計簿を見る');
        onTap = () {
          setter(SelectedNote.personal);
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

    switch (mode) {
      case SelectedNote.personal:
        icon = const Icon(
          Icons.person,
          color: Colors.white,
        );
        break;

      case SelectedNote.shared:
        icon = const Icon(
          Icons.group,
          color: Colors.white,
        );
        break;
    }

    return icon;
  }
}
