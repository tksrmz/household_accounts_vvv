import 'dart:async';

import 'package:household_accounts/data/repositories/record/record_repository.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:household_accounts/domain/models/record.dart';

/// Resultを返すinterfaceはmockitoでモック生成できないため手書きFakeを共用する
class FakeRecordRepository implements RecordRepository {
  /// [watchPeriod]が返すストリーム。テストから任意のイベント(レコードの一覧・
  /// エラー)を流せる。
  final StreamController<List<Record>> recordsController =
      StreamController<List<Record>>.broadcast();

  int watchPeriodCallCount = 0;

  Period? lastWatchedPeriod;

  @override
  Stream<List<Record>> watchPeriod(Period period) {
    watchPeriodCallCount++;
    lastWatchedPeriod = period;
    return recordsController.stream;
  }
}
