import 'package:flutter/material.dart';
import 'package:household_accounts/adapter/controller/ctl_record_register.dart';
import 'package:household_accounts/framework/ui/ui_calendar_record_view.dart';
import 'package:household_accounts/framework/ui/ui_property_viewer.dart';
import 'package:household_accounts/framework/ui/ui_record_register.dart';
import 'package:household_accounts/use_case/uc_record_register.dart';
import 'package:household_accounts/use_case/uc_repository.dart';
import 'framework/db/db_record_repository.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
              title: 'Household Accounts',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: Scaffold(
                body: Center(
                  child: Text('Something went wrong'),
                ),
              ));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
            title: 'Household Accounts',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
              body: Center(
                child: Text('Loading'),
              ),
            ));
      },
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final recordRegisterPage = _HomeWidgetContent(
      title: 'Input',
      builder: () {
        final RecordRepositoryInterface rrif = FirestoreRecordRepository();
        final RecordRegisterInputPort rrip = RecordRegisterInputHandler(rrif);
        final RecordRegisterController rrct = RecordRegisterController(rrip);
        return RecordRegisterPage(rrct);
      },
      iconData: Icons.cloud,
    );

    final calenderViewPage = _HomeWidgetContent(
      title: 'Calendar',
      builder: () {
        final RecordRepositoryInterface rrif = FirestoreRecordRepository();
        return CalendarRecordViewPage(rrif);
      },
      iconData: Icons.beach_access,
    );

    final propertyPage = _HomeWidgetContent(
      title: 'Balance',
      builder: () => const PropertyViewerPage(),
      iconData: Icons.access_alarm,
    );

    return MaterialApp(
      title: 'Household Accounts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _HomeWidget(
        [
          recordRegisterPage,
          calenderViewPage,
          propertyPage,
        ],
      ),
    );
  }
}

@immutable
class _HomeWidgetContent {
  final String title;
  final Widget Function() builder;
  final IconData iconData;

  _HomeWidgetContent(
      {required String title,
      required Widget Function() builder,
      required IconData iconData})
      : title = title,
        builder = builder,
        iconData = iconData;
}

class _HomeWidget extends StatefulWidget {
  final List<_HomeWidgetContent> contents;

  const _HomeWidget(this.contents, {Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contents[_selectedIndex].title),
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
