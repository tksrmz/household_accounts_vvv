import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test-util/golden_test_config.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  configureGoldenFileComparator();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final Future<ByteData> font = rootBundle.load('fonts/NotoSansJP.ttf');
    final FontLoader fontLoader = FontLoader('NotoSansJP')..addFont(font);
    await fontLoader.load();
  });

  await testMain();
}
