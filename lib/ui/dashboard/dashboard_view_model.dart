import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../../data/repositories/profile/profile_repository.dart';
import '../../data/repositories/record/record_repository.dart';
import '../../domain/models/notebook.dart';
import '../../domain/models/period.dart';
import '../../domain/models/record.dart';
import '../../domain/models/record_summary.dart';
import '../../domain/models/user_id.dart';
import '../../domain/models/user_name.dart';
import '../../utils/command.dart';
// utils/result.dartが独自の`Error<T>`(Resultの失敗variant)を公開しており、
// dart:coreの`Error`(Error.throwWithStackTrace)と名前が衝突する。この
// ファイルは両方を使うため、既定ではdart:core側を残し(hide)、Resultの
// 失敗variantは`result`プレフィックス経由で参照する。
import '../../utils/result.dart' hide Error;
import '../../utils/result.dart' as result show Error;

/// ダッシュボード画面の状態を持つViewModel。
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required RecordRepository recordRepository,
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
    required Notebook notebook,
    required Period period,
  }) : _profileRepository = profileRepository,
       _notebook = notebook,
       // ダッシュボードは認証済みでのみ到達する(routerのredirectが保証)
       _userId = authRepository.getCurrentUser().uid {
    // 画面を開いた時点で読み込みを始める(Viewからの明示的な初期化呼び出しは不要)
    load = Command0(_load)..execute();
    // レコードの購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態(実行中/完了/エラー)を扱う型で
    // あり、完了せず流れ続ける購読はその型に載らない。購読の結果はこのVMの
    // フィールド([summary]・[recordsError])で表す。
    _subscription = recordRepository
        .watchPeriod(period)
        .listen(_onRecords, onError: _onRecordsError);
  }

  final ProfileRepository _profileRepository;
  final Notebook _notebook;
  final UserId _userId;

  late final StreamSubscription<List<Record>> _subscription;

  /// ユーザー名の読み込みコマンド。生成と同時に実行される。
  late final Command0<void> load;

  UserName? _userName;

  /// 表示するユーザー名。読み込み完了前は`null`。
  UserName? get userName => _userName;

  RecordSummary? _summary;

  /// 期間中のレコードの集計。最初のレコードが届く前は`null`。
  ///
  /// 集計はレコードを受け取った時点で1度だけ計算して保持する(getterで毎回
  /// 計算すると、再描画のたびに同じ集計を繰り返すことになるため)。
  RecordSummary? get summary => _summary;

  Exception? _recordsError;

  /// レコードの購読で発生した想定内の失敗。発生していなければ`null`。
  Exception? get recordsError => _recordsError;

  /// 表示中のノートが個人ノートかどうか。
  bool get isPersonal => _notebook is PersonalNotebook;

  void _onRecords(List<Record> records) {
    _summary = RecordSummary.from(records);
    // 後続のスナップショットで回復しうるため、正常な発行でエラーを解消する
    _recordsError = null;
    notifyListeners();
  }

  /// [Result.guard]と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  void _onRecordsError(Object error, StackTrace stackTrace) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      'レコードの購読が失敗しました',
      name: 'DashboardViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
    _recordsError = error;
    notifyListeners();
  }

  // ここでnotifyListenersを呼ばない理由:
  // 読み込み完了の通知は[load]コマンド自身が行い、Viewは[load]とこのVMの
  // 両方を購読している。VMからも通知すると二重通知になるうえ、画面を離れて
  // VMがdisposeされたあとに読み込みが完了した場合、破棄済みのChangeNotifierへ
  // 通知してしまう(コマンドはVMのライフサイクルから独立している)。
  Future<Result<void>> _load() async {
    final fetched = await _profileRepository.fetchUserName(_userId);
    switch (fetched) {
      case Ok(:final value):
        _userName = value;
        return const Result.ok(null);
      case result.Error(:final error):
        return Result.error(error);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
