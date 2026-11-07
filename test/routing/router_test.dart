import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:household_accounts/routing/router.dart';
import 'package:household_accounts/routing/routes.dart';

import '../test-util/fake_auth_repository.dart';

void main() {
  late GoRouter router;
  late ChangeNotifier refreshListenable;

  setUp(() {
    refreshListenable = ChangeNotifier();
    router = createRouter(
      authRepository: FakeAuthRepository(),
      refreshListenable: refreshListenable,
    );
  });

  tearDown(() {
    router.dispose();
    refreshListenable.dispose();
  });

  // 資産・カテゴリのエディタのパスはシェル内の一覧(/properties・/categories)と
  // 先頭を共有するため、一覧のルートに吸い込まれずエディタのルートへ一致することを
  // 固定する
  for (final path in [
    Routes.properties,
    Routes.propertyNew,
    Routes.propertyEdit,
    Routes.categories,
    Routes.categoryNew,
    Routes.categoryEdit,
  ]) {
    test('$pathへ遷移するとき、同じパスのルートに一致すること', () {
      final matches = router.configuration.findMatch(Uri.parse(path));

      expect(matches.last.route.path, path);
    });
  }
}
