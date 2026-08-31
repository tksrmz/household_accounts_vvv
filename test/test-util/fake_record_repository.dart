import 'dart:async';

import 'package:household_accounts/data/repositories/record/record_repository.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_content.dart';
import 'package:household_accounts/utils/result.dart';

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

  /// [add]が返す結果。テストから成功/失敗を差し替えられる。
  Result<void> addResult = const Result.ok(null);

  /// 設定すると[add]がこのCompleterのFutureを返す。
  /// 完了しないCompleterを渡せば保存中の状態を再現できる。
  Completer<Result<void>>? addCompleter;

  int addCallCount = 0;

  RecordContent? lastAddedRecord;

  @override
  Future<Result<void>> add(RecordContent record) {
    addCallCount++;
    lastAddedRecord = record;

    final completer = addCompleter;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(addResult);
  }
}
