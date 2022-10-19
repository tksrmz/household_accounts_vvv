import 'package:flutter/material.dart';

import '../../util/type/single_or_pair.dart';

class MainPageDrawer extends StatelessWidget {
  const MainPageDrawer({
    required this.mode,
    this.setter,
    Key? key,
  }) : super(key: key);

  final SingleOrPair mode;
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
          setter != null ? _getListTile(context, setter!) : SizedBox.shrink(),
        ],
      ),
    );
  }

  String _getHeaderTitle() {
    final modeText;

    switch (mode) {
      case SingleOrPair.single:
        modeText = 'Personal mode';
        break;

      case SingleOrPair.pair:
        modeText = 'Pair mode';
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
        title = Text('Change to pair mode.');
        onTap = () {
          setter(SingleOrPair.pair);
          Navigator.pop(context); // close the drawer
        };
        break;

      case SingleOrPair.pair:
        title = Text('Change to personal mode.');
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
