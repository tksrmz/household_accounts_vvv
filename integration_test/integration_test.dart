import 'dashboard_feature_test.dart';

void main() async {
  final integrationTests = <Future<void> Function()>[
    dashboardFeature,
  ];
  for (final test in integrationTests) {
    await test();
  }
}
