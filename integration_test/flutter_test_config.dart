import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';
import 'package:integration_test/integration_test.dart';

/// setUpとtearDownはすべてのIntegrationTestで必要になるため、ここにまとめておく
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    // awaitしないとFirebase初期化とテスト本体のpumpWidgetが競合し、
    // [core/no-app] No Firebase App '[DEFAULT]' has been created で失敗する
    await initializeFirebaseApp();
  });

  tearDown(() {
    // log out
    FirebaseAuth.instance.signOut();
  });

  await testMain();
}
