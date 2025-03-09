import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/main.dart';
import 'package:household_accounts/util/service_locator/main.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  initializeFirebaseApp();
  initializeServiceLocator();

  testWidgets('launching app', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
