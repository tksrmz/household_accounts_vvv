// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/constant/firebase_constant.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../common_widget/loading.dart';
import '../util/future_builder_helper.dart';
import '../util/model/user_info.dart' as myapp;

// import '../../util/constant/firebase_constant.dart';
// import '../../util/service_locator/main.dart';
// import '../../util/type/single_or_pair.dart';
// import '../budget_viewer/budget_viewer_page.dart';
// import '../category_viewer/category_viewer_page.dart';
// import '../main_page/main_page.dart';
// import '../monthly_record_viewer/monthly_record_viewer_page.dart';
// import '../property_viewer/property_viewer_page.dart';
// import '../record_register/record_register_page.dart';

class MyAppHome extends StatefulWidget {
  const MyAppHome({
    required this.uid,
    Key? key,
  }) : super(key: key);

  final String uid;

  @override
  State<MyAppHome> createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  late final Future<DocumentSnapshot<Map<String, dynamic>>>
      _privateProfileFuture;

  @override
  void initState() {
    super.initState();
    _privateProfileFuture = FirebaseFirestore.instance
        .collection('/$FIREBASE_COLLECTION_PRIVATE_PROFILES')
        .doc(widget.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _privateProfileFuture,
      builder: (context, snapshot) {
        return FutureBuilderHelper<DocumentSnapshot<Map<String, dynamic>>>(
          snapshot: snapshot,
          onSuccess: _onSuccess,
          onError: _onError,
          onLoading: _onLoading,
        );
      },
    );
  }

  Widget _onSuccess(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic>? sharedNote = snapshot.get('sharedNote');
    final String? pairId;
    if (sharedNote == null) {
      pairId = null;
    } else {
      final DocumentReference ref = sharedNote['ref'] as DocumentReference;
      pairId = ref.id;
    }

    final info = myapp.UserInfo(
      uid: widget.uid,
      pairId: pairId,
    );
    return Provider<myapp.UserInfo>.value(
      value: info,
      child: _MainPage(),
    );
  }

  Widget _onError(BuildContext context, Object error) {
    return Scaffold(
      body: Center(
        child: Text(error.toString()),
      ),
    );
  }

  Widget _onLoading(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingWidget(),
      ),
    );
  }
}

class _MainPage extends StatefulWidget {
  const _MainPage({Key? key}) : super(key: key);

  @override
  State<_MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<_MainPage> {
  final _titles = [
    'index 0',
    'index 1',
    'index 2',
  ];
  SingleOrPair _singleOrPair = SingleOrPair.single;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final bodies = _titles.map((title) => _PageBody(text: title));

    return Scaffold(
      appBar: _AppHomePageAppBar(
        title: _titles[_index],
      ),
      drawer: _AppHomePageDrawer(
        mode: _singleOrPair,
        setter:
            context.read<myapp.UserInfo>().hasPair ? _setSingleOrPair : null,
      ),
      body: Provider<SingleOrPair>.value(
        value: _singleOrPair,
        child: bodies.elementAt(_index),
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
        ],
        currentIndex: _index,
        onTap: _onTapped,
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

class _AppHomePageAppBar extends AppBar {
  _AppHomePageAppBar({
    required String title,
    Key? key,
  }) : super(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await sl.reset();
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
          key: key,
        );
}

class _AppHomePageDrawer extends StatelessWidget {
  const _AppHomePageDrawer({
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

// class MyAppHome extends StatefulWidget {
//   final String _uid;
//
//   const MyAppHome({
//     Key? key,
//     required String uid,
//   })  : _uid = uid,
//         super(key: key);
//
//   @override
//   State<MyAppHome> createState() => MyAppHomeState();
// }
//
// class MyAppHomeState extends State<MyAppHome> {
//   late final Future<DocumentSnapshot<Map<String, dynamic>>>
//   _privateProfileDocSnapshot;
//   SingleOrPair _singleOrPair = SingleOrPair.single;
//
//   @override
//   void initState() {
//     super.initState();
//     _privateProfileDocSnapshot = FirebaseFirestore.instance
//         .collection('/$FIREBASE_COLLECTION_PRIVATE_PROFILES')
//         .doc(widget._uid)
//         .get();
//   }
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//       future: _privateProfileDocSnapshot,
//       builder: (context, snapshot) {
//         // Check for errors
//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(
//               child: Text('Something went wrong'),
//             ),
//           );
//         }
//
//         // Once complete, show your application
//         if (snapshot.connectionState == ConnectionState.done) {
//           final recordRegisterPage = MainPageContent(
//             title: 'Input',
//             builder: () => RecordInputPage(),
//             iconData: Icons.cloud,
//           );
//
//           final calenderViewPage = MainPageContent(
//             title: 'Calendar',
//             builder: () => CalendarRecordViewPage2(),
//             iconData: Icons.beach_access,
//           );
//
//           final propertyPage = MainPageContent(
//             title: 'Property',
//             builder: () => PropertyListPage(),
//             iconData: Icons.access_alarm,
//           );
//
//           final categoryListPage = MainPageContent(
//             title: 'Categories',
//             builder: () => CategoryListPage2(),
//             iconData: Icons.accessibility,
//           );
//
//           final budgetListPage = MainPageContent(
//             title: 'Budget',
//             builder: () => BudgetViewerPage(),
//             iconData: Icons.next_plan_outlined,
//           );
//
//           return MainPage(
//             [
//               recordRegisterPage,
//               calenderViewPage,
//               propertyPage,
//               categoryListPage,
//               budgetListPage,
//             ],
//             singleOrPair: _singleOrPair,
//             setSingleOrPair: snapshot.data!.exists &&
//                 snapshot.data!.get('sharedNote') != null
//                 ? (newValue) async {
//               await sl.reset();
//               setState(
//                     () {
//                   _singleOrPair = newValue;
//                 },
//               );
//             }
//                 : null,
//           );
//         }
//
//         // Otherwise, show something whilst waiting for initialization to complete
//         return Scaffold(
//           body: Center(
//             child: Text('Loading'),
//           ),
//         );
//       },
//     );
//   }
// }
