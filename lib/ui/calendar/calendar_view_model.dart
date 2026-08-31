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
  CalendarViewModel({
    required RecordRepository recordRepository,
    required int currentYear,
    required int currentMonth,
  }) : _recordRepository = recordRepository,
       _currentYear = currentYear,
       _currentMonth = currentMonth,
       _year = currentYear,
       _month = currentMonth {
    // レコードの購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態(実行中/完了/エラー)を扱う型で
    // あり、完了せず流れ続ける購読はその型に載らない。購読の結果はこのVMの
    // フィールド([dailySummaries]・[recordsError])で表す。
    _subscribe();
  }

  final RecordRepository _recordRepository;

  // 「今日が属する月」は画面を開いた時点の値で固定する。表示月の初期値と
  // 翌月へ進めるかの判定にだけ使うため、日をまたいだ追随は必要ない。
  final int _currentYear;
  final int _currentMonth;

  late StreamSubscription<List<Record>> _subscription;

  int _year;

  /// 表示中の年。
  int get year => _year;

  int _month;

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
  bool get canShowNextMonth => _isBefore(
    year: _year,
    month: _month,
    otherYear: _currentYear,
    otherMonth: _currentMonth,
  );

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
