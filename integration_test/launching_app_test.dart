import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:household_accounts/main.dart';
import 'package:household_accounts/util/service_locator/main.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
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

  testWidgets('launching app', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('Displays loading screen after sign in', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration!.labelText == "Email",
        description: "with email text field",
      ),
      "hogehoge@example.com",
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration!.labelText == "Password",
        description: "with password text field",
      ),
      "abc1234",
    );
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is OutlinedButton &&
            (widget.child as dynamic)!.label == "Sign in",
        description: "with sign in button",
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Loading...'), findsOneWidget);
  });
}
