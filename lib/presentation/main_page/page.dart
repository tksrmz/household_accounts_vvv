import 'package:flutter/material.dart';
import 'package:household_accounts/presentation/dashboard/page.dart';
import 'package:provider/provider.dart';

import '../../util/type/single_or_pair.dart';
import '../budget_viewer/budget_viewer_page.dart';
import '../category_viewer/category_viewer_page.dart';
import '../dashboard/view_model.dart';
import '../monthly_record_viewer/monthly_record_viewer_page.dart';
import '../property_viewer/property_viewer_page.dart';
import '../record_register/record_register_page.dart';
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
    'Dashboard',
    'Input',
    'Calendar',
    'Property',
    'Category',
    'Budget',
  ];
  SingleOrPair _singleOrPair = SingleOrPair.single;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final bodies = <Widget>[
      DashboardPage(
        date: DateTime.now(),
        viewModel: SummaryViewModel(),
      ),
      RecordInputPage(),
      CalendarRecordViewPage(),
      PropertyListBody(),
      CategoryListPage(),
      BudgetViewerPage(),
    ];

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
            icon: Icon(Icons.sunny),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Input',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'Property',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.next_plan_outlined),
            label: 'Budget',
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
