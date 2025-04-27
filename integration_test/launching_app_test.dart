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

  testWidgets('Displays summary info', (tester) async {
    await tester.pumpWidget(const MyApp());
    await singInApp(tester, "single_user@example.com", "abc1234");

    // Display loading screen
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for loading to finish.
    // The number of pumps will not be checked as it does not matter that how long it takes
    await tester.pumpAndSettle();
    expect(find.text("収入"), findsOneWidget);
    expect(find.text("¥2"), findsOneWidget);
    expect(find.text("支出"), findsOneWidget);
    expect(find.text("¥3"), findsOneWidget);
    expect(find.text("残高"), findsOneWidget);
    expect(find.text("-¥1"), findsOneWidget);
    // out of scope for this sprint
    // expect(find.byType(BudgetGraph), findsOneWidget);
  });

  testWidgets('Displays no summary for new user', (tester) async {
    await tester.pumpWidget(const MyApp());
    await singInApp(tester, "new_user@example.com", "abc1234");

    // Display loading screen
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for loading to finish.
    // The number of pumps will not be checked as it does not matter that how long it takes
    await tester.pumpAndSettle();
    expect(find.text("収入"), findsOneWidget);
    expect(find.text("支出"), findsOneWidget);
    expect(find.text("残高"), findsOneWidget);
    expect(find.text("¥0"), findsNWidgets(3)); // 収入、支出、残高で3回
    // out of scope for this sprint
    // expect(find.byType(BudgetGraph), findsOneWidget);
  });

  testWidgets('Displays summary info in pair mode', (tester) async {
    await tester.pumpWidget(const MyApp());
    await singInApp(tester, "pair_user@example.com", "abc1234");

    // Display loading screen
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for loading to finish and the dashboard to be displayed
    await tester.pumpAndSettle();

    // Open the navigation menu
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text("自分の家計簿"), findsOneWidget);

    // Change to pair mode
    await tester.tap(find.text("ふたりの家計簿を見る"));
    await tester.pumpAndSettle();
    expect(find.text("収入"), findsOneWidget);
    expect(find.text("¥20"), findsOneWidget);
    expect(find.text("支出"), findsOneWidget);
    expect(find.text("¥9"), findsOneWidget);
    expect(find.text("残高"), findsOneWidget);
    expect(find.text("¥11"), findsOneWidget);
  });
}

Future<void> singInApp(
  WidgetTester tester,
  String email,
  String password,
) async {
  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration!.labelText == "Email",
      description: "with email text field",
    ),
    email,
  );
  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration!.labelText == "Password",
      description: "with password text field",
    ),
    password,
  );
  await tester.tap(
    find.byWidgetPredicate(
      (widget) =>
          widget is OutlinedButton &&
          (widget.child as dynamic)!.label == "Sign in",
      description: "with sign in button",
    ),
  );
}
