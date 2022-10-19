// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/presentation/main_page/page.dart';
import 'package:provider/provider.dart';

import '../../util/constant/firebase_constant.dart';
import '../common_widget/loading.dart';
import '../util/future_builder_helper.dart';
import '../util/model/user_info.dart';

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

    final info = UserInfo(
      uid: widget.uid,
      pairId: pairId,
    );
    return Provider<UserInfo>.value(
      value: info,
      child: MainPage(),
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
