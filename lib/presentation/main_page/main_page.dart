import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/util/service_locator/main.dart';
import 'package:household_accounts/util/type/single_or_pair.dart';

@immutable
class MainPageContent {
  final String title;
  final Widget Function() builder;
  final IconData iconData;

  MainPageContent({
    required String title,
    required Widget Function() builder,
    required IconData iconData,
  })  : title = title,
        builder = builder,
        iconData = iconData;
}

class MainPage extends StatefulWidget {
  final List<MainPageContent> contents;
  final SingleOrPair _singleOrPair;
  final void Function(SingleOrPair newValue)? _setSingleOrPair;

  const MainPage(
    this.contents, {
    Key? key,
    required SingleOrPair singleOrPair,
    required void Function(SingleOrPair newValue)? setSingleOrPair,
  })  : _singleOrPair = singleOrPair,
        _setSingleOrPair = setSingleOrPair,
        super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late final List<BottomNavigationBarItem> _bottomNavigationBarItems;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _bottomNavigationBarItems = List.of(
      widget.contents.map<BottomNavigationBarItem>(
        (e) => BottomNavigationBarItem(
          icon: Icon(e.iconData),
          label: e.title,
        ),
      ),
      growable: false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String modeText;
    Widget modeListTile;
    Icon modeIcon;
    switch (widget._singleOrPair) {
      case SingleOrPair.single:
        modeText = 'Personal mode';
        modeListTile = widget._setSingleOrPair != null
            ? ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: Text('Change to pair mode.'),
                onTap: () {
                  widget._setSingleOrPair!(SingleOrPair.pair);
                  Navigator.pop(context); // close the drawer
                })
            : SizedBox.shrink();
        modeIcon = const Icon(
          Icons.person,
          color: Colors.white,
        );
        break;
      case SingleOrPair.pair:
        modeText = 'Pair mode';
        modeListTile = widget._setSingleOrPair != null
            ? ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: Text('Change to personal mode.'),
                onTap: () {
                  widget._setSingleOrPair!(SingleOrPair.single);
                  Navigator.pop(context); // close the drawer
                })
            : SizedBox.shrink();
        modeIcon = const Icon(Icons.group, color: Colors.white);
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contents[_selectedIndex].title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await sl.reset();
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      drawer: Drawer(
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
                    child: modeIcon,
                  ),
                  Text(
                    modeText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            modeListTile,
          ],
        ),
      ),
      body: widget.contents[_selectedIndex].builder(),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavigationBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
