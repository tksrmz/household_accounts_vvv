import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/record/record_repository.dart';
import '../../domain/models/daily_summary.dart';
import '../../domain/models/period.dart';
import '../../domain/models/record.dart';

/// 月次カレンダー画面の状態を持つViewModel。
class CalendarViewModel extends ChangeNotifier {
  /// [now]は現在日時の取得手段。本番は既定値のままでよく、テストが固定日時を
  /// 注入するための口である(Repositoryではないため、VMへのRepository注入規約
  /// とは別枠の、決定的テストのための時計注入)。
  CalendarViewModel({
    required RecordRepository recordRepository,
    DateTime Function() now = DateTime.now,
  }) : _recordRepository = recordRepository,
       _now = now {
    // 表示月の初期値は「今日が属する月」。年月を別々に取得すると日跨ぎで
    // 食い違いうるため、1回の取得値から両方を決める。
    final today = now();
    _year = today.year;
    _month = today.month;
    _knownTodayYear = today.year;
    _knownTodayMonth = today.month;
    // レコードの購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態(実行中/完了/エラー)を扱う型で
    // あり、完了せず流れ続ける購読はその型に載らない。購読の結果はこのVMの
    // フィールド([dailySummaries]・[recordsError])で表す。
    _subscribe();
  }

  final RecordRepository _recordRepository;

  final DateTime Function() _now;

  late StreamSubscription<List<Record>> _subscription;

  late int _year;

  /// 表示中の年。
  int get year => _year;

  late int _month;

  /// 表示中の月(1〜12)。
  int get month => _month;

  Map<int, DailySummary>? _dailySummaries;

  /// 表示中の月の日(1〜31)ごとの集計。最初のレコードが届く前は`null`。
  ///
  /// レコードが1件もない日はキーを持たない(ゼロ埋めした日セルを描くかどうかは
  /// 表示側の関心事)。集計はレコードを受け取った時点で1度だけ計算して保持する
  /// (getterで毎回計算すると、再描画のたびに同じ集計を繰り返すことになるため)。
  Map<int, DailySummary>? get dailySummaries => _dailySummaries;

  Exception? _recordsError;

  /// レコードの購読で発生した想定内の失敗。発生していなければ`null`。
  Exception? get recordsError => _recordsError;

  /// 翌月へ進めるかどうか。
  ///
  /// 未来の月は集計する対象がないため進めない(過去へは制限なく遡れる)。
  /// 「今日が属する月」は評価のたびに取り直す。生成時の値で固定すると、
  /// タブがIndexedStackに保持されたまま月をまたいだとき、新しい当月へ
  /// 進めなくなるため。
  bool get canShowNextMonth {
    final today = _now();
    return _isBefore(
      year: _year,
      month: _month,
      otherYear: today.year,
      otherMonth: today.month,
    );
  }

  // refreshCurrentMonthが「前回確認した今日の月」として比較する値。
  // canShowNextMonthは評価のたびに_now()を見るため常に正しいが、時間の経過
  // 自体は再描画の契機を持たない。この値との差分で通知の要否を決める。
  late int _knownTodayYear;
  late int _knownTodayMonth;

  /// 「今日が属する月」が前回の確認から変わっていれば、画面へ再描画を通知する。
  ///
  /// 時間の経過はStreamのような通知を持たないため、アプリの復帰など
  /// 「日時が進んでいそうな契機」にホストがこれを呼ぶ。月が変わっていれば
  /// 翌月へ進むボタンの活性([canShowNextMonth])が表示に追随する。
  void refreshCurrentMonth() {
    final today = _now();
    if (today.year == _knownTodayYear && today.month == _knownTodayMonth) {
      return;
    }
    _knownTodayYear = today.year;
    _knownTodayMonth = today.month;
    notifyListeners();
  }

  /// 前の月を表示する。
  void showPreviousMonth() => _showMonthAt(-1);

  /// 次の月を表示する。[canShowNextMonth]が`false`のときは何もしない。
  void showNextMonth() {
    if (!canShowNextMonth) {
      return;
    }
    _showMonthAt(1);
  }

  /// 表示月を[delta]か月ずらし、その月のレコードを購読し直す。
  ///
  /// 月ごとにViewModel(と画面)を作り直さないのは、月送りが同じ画面上の
  /// 操作だからである。表示月はこのVMの状態として持ち、購読だけを張り替える。
  void _showMonthAt(int delta) {
    // DateTimeの正規化に年またぎ(12月の翌月・1月の前月)の計算を任せる
    final shifted = DateTime(_year, _month + delta);
    _year = shifted.year;
    _month = shifted.month;
    // 新しい月の集計が届くまではローディングに戻す(前の月の集計を
    // 新しい月のものとして見せないため)。前の月の失敗も引き継がない。
    _dailySummaries = null;
    _recordsError = null;
    _subscription.cancel();
    _subscribe();
    notifyListeners();
  }

  void _subscribe() {
    _subscription = _recordRepository
        .watchPeriod(Period.calendarMonth(_year, _month))
        .listen(_onRecords, onError: _onRecordsError);
  }

  void _onRecords(List<Record> records) {
    _dailySummaries = DailySummary.byDay(records);
    // 後続のスナップショットで回復しうるため、正常な発行でエラーを解消する
    _recordsError = null;
    notifyListeners();
  }

  /// `Result.guard`と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  void _onRecordsError(Object error, StackTrace stackTrace) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      'レコードの購読が失敗しました',
      name: 'CalendarViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
    _recordsError = error;
    notifyListeners();
  }

  // 状態を読むgetterではなく比較する年月を引数に取る純粋関数にする:
  // 「どの年月同士の比較か」が呼び出し側で明示される
  static bool _isBefore({
    required int year,
    required int month,
    required int otherYear,
    required int otherMonth,
  }) => year < otherYear || (year == otherYear && month < otherMonth);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
