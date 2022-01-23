import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/data/repositories/category_repository.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/presentation/pages/category_list.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/add_properties.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/update_property.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/category-page/domain/repositories/category_repository.dart';
import 'features/category-page/domain/use-cases/add_category.dart';
import 'features/category-page/domain/use-cases/update_category.dart';
import 'features/property-viewer/data/repositories/property_repository.dart';
import 'features/property-viewer/domain/repositories/property_repository.dart';
import 'features/property-viewer/domain/use-cases/delete_property.dart';
import 'features/property-viewer/domain/use-cases/retrieve_properties.dart';
import 'features/property-viewer/presentation/pages/property_list.dart';

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
    // final recordRegisterPage = _HomeWidgetContent(
    //   title: 'Input',
    //   builder: () {
    //     final RecordRepositoryInterface rrif = InMemoryRecordRepository();
    //     final RecordRegisterInputPort rrip = RecordRegisterInputHandler(rrif);
    //     final RecordRegisterController rrct = RecordRegisterController(rrip);
    //     return RecordRegisterPage(rrct);
    //   },
    //   iconData: Icons.cloud,
    // );
    //
    // final calenderViewPage = _HomeWidgetContent(
    //   title: 'Calendar',
    //   builder: () {
    //     final repository = InMemoryRecordRepository();
    //     return MultiProvider(
    //       providers: [
    //         Provider<RetrieveMonthlyRecordsUseCase>(
    //           create: (ctx) => RetrieveMonthlyRecordsInteractor(repository),
    //         ),
    //         Provider<RetrieveDailyRecordsUseCase>(
    //           create: (ctx) => RetrieveDailyRecordsInteractor(repository),
    //         ),
    //         Provider<RecordDeleteUseCase>(
    //           create: (ctx) => RecordDeleteInteractor(repository),
    //         ),
    //       ],
    //       child: CalendarRecordViewPage2(),
    //     );
    //   },
    //   iconData: Icons.beach_access,
    // );

    final propertyPage = _HomeWidgetContent(
      title: 'Balance',
      builder: () {
        final PropertyRepository repository = InMemoryPropertyRepository();
        return MultiProvider(
          providers: [
            Provider<RetrievePropertiesUseCase>(
              create: (ctx) => RetrievePropertiesInteractor(repository),
            ),
            Provider<AddPropertiesUseCase>(
              create: (ctx) => AddPropertyInteractor(repository),
            ),
            Provider<UpdatePropertyUseCase>(
              create: (ctx) => UpdatePropertyInteractor(repository),
            ),
            Provider<DeletePropertiesUseCase>(
              create: (ctx) => DeletePropertyInteractor(repository),
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
        final CategoryRepository repository = InMemoryCategoryRepository();
        return MultiProvider(
          providers: [
            Provider<RetrieveCategoriesUseCase>(
              create: (ctx) => RetrieveCategoriesInteractor(repository),
            ),
            Provider<DeleteCategoryUseCase>(
              create: (ctx) => DeleteCategoryInteractor(repository),
            ),
            Provider<AddCategoryUseCase>(
              create: (ctx) => AddCategoryInteractor(repository),
            ),
            Provider<UpdateCategoryUseCase>(
              create: (ctx) => UpdateCategoryInteractor(repository),
            ),
          ],
          child: CategoryListPage(),
        );
      },
      iconData: Icons.accessibility,
    );

    final dummyPage = _HomeWidgetContent(
        title: 'Dummy',
        builder: () {
          return Center(child: Text('Dummy'));
        },
        iconData: Icons.note);

    return MaterialApp(
      title: 'Household Accounts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _HomeWidget(
        [
          // recordRegisterPage,
          // calenderViewPage,
          propertyPage,
          categoryListPage,
          dummyPage,
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
