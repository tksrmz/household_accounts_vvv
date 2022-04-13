import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:household_accounts/features/category-page/data/repositories/firebase_category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/features/input-page/data/repositories/firebase_record_repository.dart';
import 'package:household_accounts/features/property-viewer/data/repositories/firebase_property_repository.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_daily_records.dart';
import 'package:household_accounts/features/record-calendar-page/domain/use-cases/retrieve_monthly_records.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/presentation/pages/category_list.dart';
import 'package:household_accounts/features/input-page/presentation/pages/input_page.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/add_properties.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/update_property.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/category-page/domain/interactors/retrieve_categories.dart';
import 'features/category-page/domain/use-cases/add_category.dart';
import 'features/category-page/domain/use-cases/update_category.dart';
import 'features/input-page/domain/repositories/record_repository.dart';
import 'features/input-page/domain/use-cases/add_record.dart';
import 'features/property-viewer/domain/interactors/retrieve_properties.dart';
import 'features/property-viewer/domain/use-cases/delete_property.dart';
import 'features/record-calendar-page/domain/interactors/delete_record.dart';
import 'features/record-calendar-page/domain/interactors/retrieve_records.dart';
import 'features/record-calendar-page/domain/use-cases/delete_record.dart';
import 'features/record-calendar-page/presentation/pages/ui_calendar_record_view.dart';
import 'util/domain/use-cases/retrieve_properties.dart';
import 'features/property-viewer/presentation/pages/property_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// /// We are using a StatefulWidget such that we only create the [Future] once,
// /// no matter how many times our widget rebuild.
// /// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
// /// would re-initialize FlutterFire and make our application re-enter loading state,
// /// which is undesired.
// class App extends StatefulWidget {
//   // Create the initialization Future outside of `build`:
//   @override
//   _AppState createState() => _AppState();
// }
//
// class _AppState extends State<App> {
//   /// The future is part of the state of our widget. We should not call `initializeApp`
//   /// directly inside [build].
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       // Initialize FlutterFire:
//       future: _initialization,
//       builder: (context, snapshot) {
//         // Check for errors
//         if (snapshot.hasError) {
//           return MaterialApp(
//               title: 'Household Accounts',
//               theme: ThemeData(
//                 primarySwatch: Colors.blue,
//               ),
//               home: Scaffold(
//                 body: Center(
//                   child: Text('Something went wrong'),
//                 ),
//               ));
//         }
//
//         // Once complete, show your application
//         if (snapshot.connectionState == ConnectionState.done) {
//           return MyApp();
//         }
//
//         // Otherwise, show something whilst waiting for initialization to complete
//         return MaterialApp(
//             title: 'Household Accounts',
//             theme: ThemeData(
//               primarySwatch: Colors.blue,
//             ),
//             home: Scaffold(
//               body: Center(
//                 child: Text('Loading'),
//               ),
//             ));
//       },
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Household Accounts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: [
              EmailProviderConfiguration(),
            ],
          );
        }

        // Render your application if authenticated
        return MyAppHome(uid: snapshot.data!.uid);
      },
    );
  }
}

class MyAppHome extends StatelessWidget {
  late final RecordRepositoryNew _firebaseRecordRepository;
  late final FirebasePropertyRepository _firebasePropertyRepository;
  late final FirebaseCategoryRepository _firebaseCategoryRepository;

  MyAppHome({Key? key, required String uid}) : super(key: key) {
    _firebaseRecordRepository = FirebaseRecordRepository.of(uid);
    _firebaseCategoryRepository = FirebaseCategoryRepository.of(uid);
    _firebasePropertyRepository = FirebasePropertyRepository.of(uid);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final recordRegisterPage = _HomeWidgetContent(
      title: 'Input',
      builder: () {
        return MultiProvider(
          providers: [
            Provider<AddIncomeRecordUseCase>(
              create: (ctx) =>
                  AddIncomeRecordInteractor(_firebaseRecordRepository),
            ),
            Provider<AddExpenseRecordUseCase>(
              create: (ctx) =>
                  AddExpenseRecordInteractor(_firebaseRecordRepository),
            ),
            Provider<AddTransferRecordUseCase>(
              create: (ctx) =>
                  AddTransferRecordInteractor(_firebaseRecordRepository),
            ),
            Provider<RetrieveCategoriesUseCase>(
              create: (ctx) =>
                  RetrieveCategoriesInteractor(_firebaseCategoryRepository),
            ),
            Provider<RetrievePropertiesUseCase>(
              create: (ctx) =>
                  RetrievePropertiesInteractor(_firebasePropertyRepository),
            ),
          ],
          child: RecordInputPage(),
        );
      },
      iconData: Icons.cloud,
    );

    final calenderViewPage = _HomeWidgetContent(
      title: 'Calendar',
      builder: () {
        return MultiProvider(
          providers: [
            Provider<RetrieveMonthlyRecordsUseCase>(
              create: (ctx) => RetrieveMonthlyRecordsInteractorNew(
                _firebaseRecordRepository,
              ),
            ),
            Provider<RetrieveDailyRecordsUseCase>(
              create: (ctx) =>
                  RetrieveDailyRecordsInteractorNew(_firebaseRecordRepository),
            ),
            Provider<DeleteRecordUseCaseNew>(
              create: (ctx) =>
                  DeleteRecordInteractorNew(_firebaseRecordRepository),
            ),
            Provider<RetrieveCategoriesUseCase>(
              create: (ctx) =>
                  RetrieveCategoriesInteractor(_firebaseCategoryRepository),
            ),
          ],
          child: CalendarRecordViewPage2(),
        );
      },
      iconData: Icons.beach_access,
    );

    final propertyPage = _HomeWidgetContent(
      title: 'Balance',
      builder: () {
        return MultiProvider(
          providers: [
            Provider<RetrievePropertiesUseCase>(
              create: (ctx) =>
                  RetrievePropertiesInteractor(_firebasePropertyRepository),
            ),
            Provider<AddPropertiesUseCase>(
              create: (ctx) =>
                  AddPropertyInteractor(_firebasePropertyRepository),
            ),
            Provider<UpdatePropertyUseCase>(
              create: (ctx) =>
                  UpdatePropertyInteractor(_firebasePropertyRepository),
            ),
            Provider<DeletePropertiesUseCase>(
              create: (ctx) =>
                  DeletePropertyInteractor(_firebasePropertyRepository),
            ),
          ],
          child: PropertyListPage(),
        );
      },
      iconData: Icons.access_alarm,
    );

    final categoryListPage = _HomeWidgetContent(
      title: 'Categories',
      builder: () {
        return MultiProvider(
          providers: [
            Provider<RetrieveCategoriesUseCase>(
              create: (ctx) =>
                  RetrieveCategoriesInteractor(_firebaseCategoryRepository),
            ),
            Provider<DeleteCategoryUseCase>(
              create: (ctx) =>
                  DeleteCategoryInteractor(_firebaseCategoryRepository),
            ),
            Provider<AddCategoryUseCase>(
              create: (ctx) =>
                  AddCategoryInteractor(_firebaseCategoryRepository),
            ),
            Provider<UpdateCategoryUseCase>(
              create: (ctx) =>
                  UpdateCategoryInteractor(_firebaseCategoryRepository),
            ),
            // Provider<RetrieveMonthlyRecordsUseCase>(
            //   create: (ctx) =>
            //       RetrieveMonthlyRecordsInteractor(_recordRepository),
            // ),
          ],
          child: CategoryListPage(),
        );
      },
      iconData: Icons.accessibility,
    );

    return _HomeWidget(
      [
        recordRegisterPage,
        calenderViewPage,
        propertyPage,
        categoryListPage,
      ],
    );
  }
}

@immutable
class _HomeWidgetContent {
  final String title;
  final Widget Function() builder;
  final IconData iconData;

  _HomeWidgetContent({
    required String title,
    required Widget Function() builder,
    required IconData iconData,
  })  : title = title,
        builder = builder,
        iconData = iconData;
}

class _HomeWidget extends StatefulWidget {
  final List<_HomeWidgetContent> contents;

  const _HomeWidget(this.contents, {Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

enum _SingleOrPair {
  single,
  pair,
}

class _HomeWidgetState extends State<_HomeWidget> {
  late final List<BottomNavigationBarItem> _bottomNavigationBarItems;
  int _selectedIndex = 0;
  _SingleOrPair _singleOrPair = _SingleOrPair.single;

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

  void _setSingleOrPair(_SingleOrPair newValue) {
    setState(() {
      _singleOrPair = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    String modeText;
    ListTile modeListTile;
    Icon modeIcon;
    switch (_singleOrPair) {
      case _SingleOrPair.single:
        modeText = 'Personal mode';
        modeListTile = ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: Text('Change to pair mode.'),
          onTap: () {
            _setSingleOrPair(_SingleOrPair.pair);
            Navigator.pop(context); // close the drawer
          },
        );
        modeIcon = const Icon(
          Icons.person,
          color: Colors.white,
        );
        break;
      case _SingleOrPair.pair:
        modeText = 'Pair mode';
        modeListTile = ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: Text('Change to personal mode.'),
          onTap: () {
            _setSingleOrPair(_SingleOrPair.single);
            Navigator.pop(context); // close the drawer
          },
        );
        modeIcon = const Icon(Icons.group, color: Colors.white);
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contents[_selectedIndex].title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
        onTap: _onItemTapped,
      ),
    );
  }
}
