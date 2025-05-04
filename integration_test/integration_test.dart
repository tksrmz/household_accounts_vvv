import 'dashboard_feature_test.dart';
import 'username_feature_test.dart';

void main() async {
  final integrationTests = <Future<void> Function()>[
    dashboardFeature,
    userNameFeature,
  ];
  for (final test in integrationTests) {
    await test();
  }
}
