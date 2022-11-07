import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/constant/firebase_constant.dart';
import '../common_widget/loading.dart';
import '../main_page/page.dart';
import '../util/future_builder_helper.dart';
import '../util/model/user_info.dart';

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
