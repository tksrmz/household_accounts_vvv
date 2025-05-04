import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../util/type/single_or_pair.dart';
import '../../v2/data/repositories/firebase_public_profile_repository.dart';
import '../../v2/domain/models/vo/user_id.dart';
import '../../v2/presentation/pages/settings/page.dart';
import '../../v2/presentation/pages/settings/view_model.dart';

class MainPageDrawer extends StatelessWidget {
  const MainPageDrawer({
    required this.mode,
    required this.userId,
    this.setter,
    Key? key,
  }) : super(key: key);

  final SingleOrPair mode;
  final UserIdVo userId;
  final void Function(SingleOrPair)? setter;

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
                      publicProfileRepository: FirebasePublicProfileRepository(
                        FirebaseFirestore.instance,
                      ),
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
      case SingleOrPair.single:
        modeText = '自分の家計簿';
        break;

      case SingleOrPair.pair:
        modeText = 'ふたりの家計簿';
        break;
    }

    return modeText;
  }

  ListTile _getListTile(
    BuildContext context,
    void Function(SingleOrPair) setter,
  ) {
    final Text title;
    final void Function() onTap;

    switch (mode) {
      case SingleOrPair.single:
        title = Text('ふたりの家計簿を見る');
        onTap = () {
          setter(SingleOrPair.pair);
          Navigator.pop(context); // close the drawer
        };
        break;

      case SingleOrPair.pair:
        title = Text('自分の家計簿を見る');
        onTap = () {
          setter(SingleOrPair.single);
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
      case SingleOrPair.single:
        icon = const Icon(
          Icons.person,
          color: Colors.white,
        );
        break;

      case SingleOrPair.pair:
        icon = const Icon(
          Icons.group,
          color: Colors.white,
        );
        break;
    }

    return icon;
  }
}
