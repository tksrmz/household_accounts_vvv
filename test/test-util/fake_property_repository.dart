import 'dart:async';

import 'package:household_accounts/data/repositories/property/property_repository.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/utils/result.dart';

/// Resultを返すinterfaceはmockitoでモック生成できないため手書きFakeを共用する
class FakePropertyRepository implements PropertyRepository {
  /// [watchAll]が返すストリーム。テストから任意のイベント(資産の一覧・エラー)を
  /// 流せる。
  final StreamController<List<Property>> propertiesController =
      StreamController<List<Property>>.broadcast();

  int watchAllCallCount = 0;

  /// [add]が返す結果。テストから差し替えて失敗を再現できる。
  Result<void> addResult = const Result.ok(null);

  /// [update]が返す結果。
  Result<void> updateResult = const Result.ok(null);

  /// [delete]が返す結果。
  Result<void> deleteResult = const Result.ok(null);

  /// [add]の呼び出し引数の記録。
  final List<({PropertyName name, int balance})> addCalls = [];

  /// [update]の呼び出し引数の記録。
  final List<({PropertyId id, PropertyName? name, int? balance})> updateCalls =
      [];

  /// [delete]の呼び出し引数の記録。
  final List<PropertyId> deleteCalls = [];

  @override
  Stream<List<Property>> watchAll() {
    watchAllCallCount++;
    return propertiesController.stream;
  }

  @override
  Future<Result<void>> add({
    required PropertyName name,
    required int balance,
  }) async {
    addCalls.add((name: name, balance: balance));
    return addResult;
  }

  @override
  Future<Result<void>> update(
    PropertyId id, {
    PropertyName? name,
    int? balance,
  }) async {
    updateCalls.add((id: id, name: name, balance: balance));
    return updateResult;
  }

  @override
  Future<Result<void>> delete(PropertyId id) async {
    deleteCalls.add(id);
    return deleteResult;
  }
}
