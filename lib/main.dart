import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:household_accounts/presentation/budget_viewer/budget_viewer_page.dart';
import 'package:household_accounts/util/service_locator/service_locator.dart';
import 'package:household_accounts/presentation/category_viewer/category_viewer_page.dart';
import 'package:household_accounts/presentation/record_register/record_register_page.dart';
import 'package:household_accounts/util/constant/firebase_constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'presentation/monthly_record_viewer/monthly_record_viewer_page.dart';
import 'presentation/property_viewer/property_viewer_page.dart';

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

class MyAppHome extends StatefulWidget {
  final String _uid;

  const MyAppHome({
    Key? key,
    required String uid,
  })  : _uid = uid,
        super(key: key);

  @override
  State<MyAppHome> createState() => MyAppHomeState();
}

class MyAppHomeState extends State<MyAppHome> {
  late final Future<DocumentSnapshot<Map<String, dynamic>>>
      _privateProfileDocSnapshot;
  _SingleOrPair _singleOrPair = _SingleOrPair.single;

  @override
  void initState() {
    super.initState();
    _privateProfileDocSnapshot = FirebaseFirestore.instance
        .collection('/$FIREBASE_COLLECTION_PRIVATE_PROFILES')
        .doc(widget._uid)
        .get();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _privateProfileDocSnapshot,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Something went wrong'),
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          switch (_singleOrPair) {
            case _SingleOrPair.single:
              initialize(widget._uid);
              break;

            case _SingleOrPair.pair:
              // _firebaseRecordRepository = FirebaseRecordRepository.shared(
              //     (snapshot.data!.get('sharedNote.ref') as DocumentReference)
              //         .id);
              // _firebasePropertyRepository = FirebasePropertyRepository.shared(
              //     (snapshot.data!.get('sharedNote.ref') as DocumentReference)
              //         .id);
              // _firebaseCategoryRepository = FirebaseCategoryRepository.shared(
              //     (snapshot.data!.get('sharedNote.ref') as DocumentReference)
              //         .id);
              break;
          }

          final recordRegisterPage = _HomeWidgetContent(
            title: 'Input',
            builder: () => RecordInputPage(),
            iconData: Icons.cloud,
          );

          final calenderViewPage = _HomeWidgetContent(
            title: 'Calendar',
            builder: () => CalendarRecordViewPage2(),
            iconData: Icons.beach_access,
          );

          final propertyPage = _HomeWidgetContent(
            title: 'Balance',
            builder: () => PropertyListPage(),
            iconData: Icons.access_alarm,
          );

          final categoryListPage = _HomeWidgetContent(
            title: 'Categories',
            builder: () => CategoryListPage2(),
            iconData: Icons.accessibility,
          );

          final budgetListPage = _HomeWidgetContent(
            title: 'Budget',
            builder: () => BudgetViewerPage(),
            iconData: Icons.next_plan_outlined,
          );

          return _HomeWidget(
            [
              recordRegisterPage,
              calenderViewPage,
              propertyPage,
              categoryListPage,
              budgetListPage,
            ],
            singleOrPair: _singleOrPair,
            setSingleOrPair: snapshot.data!.exists &&
                    snapshot.data!.get('sharedNote') != null
                ? (newValue) async {
                    await sl.reset();
                    setState(
                      () {
                        _singleOrPair = newValue;
                      },
                    );
                  }
                : null,
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(
          body: Center(
            child: Text('Loading'),
          ),
        );
      },
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
  final _SingleOrPair _singleOrPair;
  final void Function(_SingleOrPair newValue)? _setSingleOrPair;

  const _HomeWidget(
    this.contents, {
    Key? key,
    required _SingleOrPair singleOrPair,
    required void Function(_SingleOrPair newValue)? setSingleOrPair,
  })  : _singleOrPair = singleOrPair,
        _setSingleOrPair = setSingleOrPair,
        super(key: key);

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
      case _SingleOrPair.single:
        modeText = 'Personal mode';
        modeListTile = widget._setSingleOrPair != null
            ? ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: Text('Change to pair mode.'),
                onTap: () {
                  widget._setSingleOrPair!(_SingleOrPair.pair);
                  Navigator.pop(context); // close the drawer
                })
            : SizedBox.shrink();
        modeIcon = const Icon(
          Icons.person,
          color: Colors.white,
        );
        break;
      case _SingleOrPair.pair:
        modeText = 'Pair mode';
        modeListTile = widget._setSingleOrPair != null
            ? ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: Text('Change to personal mode.'),
                onTap: () {
                  widget._setSingleOrPair!(_SingleOrPair.single);
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
