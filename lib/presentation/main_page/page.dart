import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/type/single_or_pair.dart';
// import '../property_viewer/property_viewer_page.dart';
import '../util/model/user_info.dart';
import 'app_bar.dart';
import 'drawer.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _titles = [
    'index 0',
    'index 1',
    'index 2',
    'Property',
  ];
  SingleOrPair _singleOrPair = SingleOrPair.single;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final bodies =
        _titles.map<Widget>((title) => _PageBody(text: title)).toList();
    // bodies[3] = PropertyListPage();

    return Scaffold(
      appBar: MainPageAppBar(
        title: _titles[_index],
      ),
      drawer: MainPageDrawer(
        mode: _singleOrPair,
        setter: context.read<UserInfo>().hasPair ? _setSingleOrPair : null,
      ),
      body: Provider<SingleOrPair>.value(
        value: _singleOrPair,
        child: bodies[_index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarms),
            label: 'a',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.back_hand),
            label: 'b',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cable_sharp),
            label: 'c',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarms),
            label: 'Property',
          ),
        ],
        currentIndex: _index,
        onTap: _onTapped,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _onTapped(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }

  void _setSingleOrPair(SingleOrPair newValue) {
    setState(() {
      _singleOrPair = newValue;
    });
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Text(text),
        Text(context.watch<SingleOrPair>().name),
      ]),
    );
  }
}
