import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/page.dart';
import 'package:provider/provider.dart';

import '../../data/firebase/util/path_builder.dart';
import '../../util/type/single_or_pair.dart';
import '../../v2/data/repositories/firebase_expense_repository.dart';
import '../../v2/data/repositories/firebase_income_repository.dart';
import '../../v2/data/repositories/firebase_public_profile_repository.dart';
import '../../v2/domain/usecases/dashboard.dart';
import '../../v2/presentation/pages/dashboard/view_model.dart';
import '../budget_viewer/budget_viewer_page.dart';
import '../category_viewer/category_viewer_page.dart';
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
    'ダッシュボード',
    '入力',
    'カレンダー',
    '資産',
    'カテゴリ',
    '予算',
  ];
  SingleOrPair _singleOrPair = SingleOrPair.single;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final bodies = <Widget>[
      Builder(
        builder: (context) {
          final userInfo = context.read<UserInfo>();
          final isSingle = _singleOrPair == SingleOrPair.single;

          return DashboardPage(
            date: DateTime.now(),
            viewModel: DashboardViewModel(
              dashboardUseCase: DashboardUseCase(
                incomeRepository: FirebaseIncomeRepository(
                  FirebaseFirestore.instance,
                  isSingle
                      ? getPersonalIncomeRecordCollectionPath(userInfo.uid)
                      : getSharedIncomeRecordCollectionPath(userInfo.pairId!),
                ),
                expenseRepository: FirebaseExpenseRepository(
                  FirebaseFirestore.instance,
                  isSingle
                      ? getPersonalExpenseRecordCollectionPath(userInfo.uid)
                      : getSharedExpenseRecordCollectionPath(userInfo.pairId!),
                ),
                publicProfileRepository:
                    const FirebasePublicProfileRepository(),
              ),
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
            label: 'ダッシュボード',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: '入力',
          ),
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
