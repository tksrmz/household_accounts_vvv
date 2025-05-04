import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:household_accounts/main.dart';
import 'package:household_accounts/util/service_locator/main.dart';
import 'package:integration_test/integration_test.dart';

/// setUpとtearDownはすべてのIntegrationTestで必要になるため、ここにまとめておく
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    initializeFirebaseApp();
    initializeServiceLocator();
  });

  tearDown(() {
    // log out
    FirebaseAuth.instance.signOut();

    // clear service locator
    GetIt.instance.reset();
  });

  await testMain();
}
