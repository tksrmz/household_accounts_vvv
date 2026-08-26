import 'dart:async';

import 'package:household_accounts/data/repositories/property/property_repository.dart';
import 'package:household_accounts/domain/models/property.dart';

/// Resultを返すinterfaceはmockitoでモック生成できないため手書きFakeを共用する
class FakePropertyRepository implements PropertyRepository {
  /// [watchAll]が返すストリーム。テストから任意のイベント(資産の一覧・エラー)を
  /// 流せる。
  final StreamController<List<Property>> propertiesController =
      StreamController<List<Property>>.broadcast();

  int watchAllCallCount = 0;

  @override
  Stream<List<Property>> watchAll() {
    watchAllCallCount++;
    return propertiesController.stream;
  }
}
