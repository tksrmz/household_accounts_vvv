import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/constant/firebase_constant.dart';
import '../main_page/page.dart';
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
  late final Stream<DocumentSnapshot<Map<String, dynamic>>>
      _privateProfileStream;

  @override
  void initState() {
    super.initState();
    _privateProfileStream = FirebaseFirestore.instance
        .doc('/$FIREBASE_COLLECTION_PRIVATE_PROFILES/${widget.uid}')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _privateProfileStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _onError(context, snapshot.error!);
        }

        return switch (snapshot.connectionState) {
          ConnectionState.none => _onLoading(context),
          ConnectionState.waiting => _onLoading(context),
          ConnectionState.active => snapshot.requireData.exists
              ? _onSuccess(context, snapshot.requireData)
              : _onLoading(context),
          ConnectionState.done => _onSuccess(context, snapshot.requireData),
        };
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
        child: CircularProgressIndicator(),
      ),
    );
  }
}
