import 'budget_feature_test.dart';
import 'calendar_feature_test.dart';
import 'category_feature_test.dart';
import 'dashboard_feature_test.dart';
import 'property_feature_test.dart';
import 'record_creating_feature_test.dart';
import 'shell_feature_test.dart';
import 'username_feature_test.dart';

void main() async {
  final integrationTests = <Future<void> Function()>[
    shellFeature,
    dashboardFeature,
    userNameFeature,
    recordCreatingFeature,
    calendarFeature,
    propertyFeature,
    categoryFeature,
    budgetFeature,
  ];
  for (final test in integrationTests) {
    await test();
  }
}
