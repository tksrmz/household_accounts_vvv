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

  /// [watchPeriod]で購読された期間の記録(呼び出し順)。
  final List<Period> watchedPeriods = [];

  @override
  Stream<List<Record>> watchPeriod(Period period) {
    watchPeriodCallCount++;
    lastWatchedPeriod = period;
    watchedPeriods.add(period);
    // 購読ごとに数えることで、張り替え時の購読解除漏れを検出できる
    return Stream<List<Record>>.multi((controller) {
      activeSubscriptionCount++;
      final subscription = recordsController.stream.listen(
        controller.addSync,
        onError: controller.addErrorSync,
      );
      controller.onCancel = () {
        activeSubscriptionCount--;
        return subscription.cancel();
      };
    });
  }

  /// [watchPeriod]の購読のうち、まだ解除されていないものの数。
  int activeSubscriptionCount = 0;

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

  /// [delete]が返す結果。テストから成功/失敗を差し替えられる。
  Result<void> deleteResult = const Result.ok(null);

  /// 設定すると[delete]がこのCompleterのFutureを返す。
  /// 完了しないCompleterを渡せば削除中の状態を再現できる。
  Completer<Result<void>>? deleteCompleter;

  int deleteCallCount = 0;

  Record? lastDeletedRecord;

  @override
  Future<Result<void>> delete(Record record) {
    deleteCallCount++;
    lastDeletedRecord = record;

    final completer = deleteCompleter;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(deleteResult);
  }
}
