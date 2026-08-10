import 'package:flutter/material.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/page.dart';
import 'package:provider/provider.dart';

import '../../v2/domain/models/user_auth.dart';
import '../../v2/presentation/pages/dashboard/view_model.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../budget_viewer/budget_viewer_page.dart';
import '../category_viewer/category_viewer_page.dart';
import '../monthly_record_viewer/monthly_record_viewer_page.dart';
import '../property_viewer/property_viewer_page.dart';
import '../record_register/record_register_page.dart';
import '../util/model/user_info.dart';
import 'app_bar.dart';
import 'drawer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _titles = ['ダッシュボード', '入力', 'カレンダー', '資産', 'カテゴリ', '予算'];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final bodies = <Widget>[
      Builder(
        builder: (context) {
          final now = DateTime.now();
          final userAuth = context.read<UserAuth>();
          return DashboardPage(
            viewModel: DashboardViewModel(
              incomeRepository: context.read(),
              expenseRepository: context.read(),
              publicProfileRepository: context.read(),
              date: now,
              userId: userAuth.uid,
            ),
          );
        },
      ),
      RecordInputPage(),
      CalendarRecordViewPage(),
      PropertyListBody(),
      CategoryListPage(),
      BudgetViewerPage(),
    ];

    return Scaffold(
      appBar: MainPageAppBar(title: _titles[_index]),
      drawer: MainPageDrawer(
        mode: context.watch<SelectedNoteState>().value,
        setter: context.read<UserInfo>().hasPair
            ? context.read<SelectedNoteState>().select
            : null,
      ),
      body: bodies[_index],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.sunny), label: 'ダッシュボード'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: '入力'),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: '資産'),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility),
            label: 'カテゴリ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.next_plan_outlined),
            label: '予算',
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
}
