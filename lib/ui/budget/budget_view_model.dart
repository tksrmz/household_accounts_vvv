import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/category/category_repository.dart';
import '../../data/repositories/record/record_repository.dart';
import '../../domain/models/budget_summary.dart';
import '../../domain/models/category.dart';
import '../../domain/models/fiscal_month.dart';
import '../../domain/models/period.dart';
import '../../domain/models/record.dart';

/// 予算画面で選べる期間の区切り方。
enum BudgetPeriodMode {
  /// 1日〜末日の暦月。
  calendarMonth,

  /// 16日始まりの月度([FiscalMonth])。
  fiscalMonth,
}

/// 予算画面の状態を持つViewModel。
class BudgetViewModel extends ChangeNotifier {
  /// [now]は現在日時の取得手段。本番は既定値のままでよく、テストが固定日時を
  /// 注入するための口である(Repositoryではないため、VMへのRepository注入規約
  /// とは別枠の、決定的テストのための時計注入)。
  BudgetViewModel({
    required RecordRepository recordRepository,
    required CategoryRepository categoryRepository,
    DateTime Function() now = DateTime.now,
  }) : _recordRepository = recordRepository,
       _now = now {
    // 表示期間の初期値は「今日が属する暦月」。日付を何度も取得すると日跨ぎで
    // 食い違いうるため、1回の取得値から決める。
    final today = now();
    _knownToday = _dateOnly(today);
    final (year, month) = _currentYearMonth(_mode, today);
    _year = year;
    _month = month;
    // 購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態(実行中/完了/エラー)を扱う型で
    // あり、完了せず流れ続ける購読はその型に載らない。購読の結果はこのVMの
    // フィールド([summary]・[loadError])で表す。
    //
    // カテゴリは表示期間に依存しないため、生成時に1度だけ購読する
    // (期間を変えるたびに張り替えると、カテゴリまでローディングに戻ってしまう)。
    _categoriesSubscription = categoryRepository
        .watchExpenseCategories()
        .listen(
          _onCategories,
          onError: (Object error, StackTrace stackTrace) => _onError(
            error,
            stackTrace,
            message: '支出カテゴリの購読が失敗しました',
            assign: (exception) => _categoriesError = exception,
          ),
        );
    _subscribeRecords();
  }

  final RecordRepository _recordRepository;

  final DateTime Function() _now;

  late final StreamSubscription<List<ExpenseCategory>> _categoriesSubscription;

  late StreamSubscription<List<Record>> _recordsSubscription;

  BudgetPeriodMode _mode = BudgetPeriodMode.calendarMonth;

  /// 期間の区切り方。
  BudgetPeriodMode get mode => _mode;

  late int _year;

  /// 表示中の期間の年(月度のときは「2026年7月度」の2026)。
  int get year => _year;

  late int _month;

  /// 表示中の期間の月(1〜12。月度のときは「2026年7月度」の7)。
  int get month => _month;

  /// 表示中の期間。
  Period get period => _periodOf(_mode, _year, _month);

  // 最新値とエラーは購読ごとに持つ。単一のフィールドで共有すると、失敗して
  // いない別の購読の正常値がエラーを消してしまい、失敗した購読の値は届かない
  // ままなので、画面がローディング表示に戻って抜け出せなくなる。
  List<ExpenseCategory>? _categories;
  List<Record>? _records;
  Exception? _categoriesError;
  Exception? _recordsError;

  BudgetSummary? _summary;

  /// 表示中の期間の予算の消化状況。カテゴリとレコードの両方が届くまでは`null`。
  ///
  /// 集計は値が届いた時点で1度だけ計算して保持する(getterで毎回計算すると、
  /// 再描画のたびに同じ集計を繰り返すことになるため)。
  BudgetSummary? get summary => _summary;

  /// 購読で発生した想定内の失敗。発生していなければ`null`。
  ///
  /// カテゴリとレコードのどちらか一方でも失敗していれば非null(片方だけでは
  /// 予算と支出を対比できないため、画面全体のエラーとして扱う)。
  Exception? get loadError => _categoriesError ?? _recordsError;

  /// 次の期間へ進めるかどうか。
  ///
  /// 「今日が属する期間」より先は集計する対象がないため進めない(過去へは
  /// 制限なく遡れる)。今日は評価のたびに取り直す。生成時の値で固定すると、
  /// タブがIndexedStackに保持されたまま期間をまたいだとき、新しい期間へ
  /// 進めなくなるため。
  bool get canShowNext {
    final (currentYear, currentMonth) = _currentYearMonth(_mode, _now());
    return _isBefore(
      year: _year,
      month: _month,
      otherYear: currentYear,
      otherMonth: currentMonth,
    );
  }

  // refreshTodayが「前回確認した今日」として比較する値。canShowNextは評価の
  // たびに_now()を見るため常に正しいが、時間の経過自体は再描画の契機を持たない。
  // この値との差分で通知の要否を決める。
  late DateTime _knownToday;

  /// 今日の日付が前回の確認から変わっていれば、画面へ再描画を通知する。
  ///
  /// 時間の経過はStreamのような通知を持たないため、アプリの復帰など
  /// 「日時が進んでいそうな契機」にホストがこれを呼ぶ。月度は16日に切り替わる
  /// ため、月単位ではなく日単位で比べる。
  void refreshToday() {
    final today = _dateOnly(_now());
    if (today == _knownToday) {
      return;
    }
    _knownToday = today;
    notifyListeners();
  }

  /// 期間の区切り方を[mode]へ切り替え、そのモードで今日が属する期間を表示する。
  ///
  /// 表示中の期間を引き継がないのは、暦月と月度では同じ年月でも期間が
  /// ずれるため(どちらへ寄せても意図しない期間になりうる)。
  void selectMode(BudgetPeriodMode mode) {
    if (mode == _mode) {
      return;
    }
    final (year, month) = _currentYearMonth(mode, _now());
    _mode = mode;
    _year = year;
    _month = month;
    _resubscribeRecords();
  }

  /// 前の期間を表示する。
  void showPrevious() => _showAt(-1);

  /// 次の期間を表示する。[canShowNext]が`false`のときは何もしない。
  void showNext() {
    if (!canShowNext) {
      return;
    }
    _showAt(1);
  }

  /// 表示中の年月を[delta]か月ずらす。
  ///
  /// 暦月・月度のどちらも、隣の期間は年月を1か月ずらしたものになる。
  void _showAt(int delta) {
    // DateTimeの正規化に年またぎ(12月の翌月・1月の前月)の計算を任せる
    final shifted = DateTime(_year, _month + delta);
    _year = shifted.year;
    _month = shifted.month;
    _resubscribeRecords();
  }

  /// 表示中の期間のレコードを購読し直す。
  void _resubscribeRecords() {
    // 新しい期間のレコードが届くまではローディングに戻す(前の期間の集計を
    // 新しい期間のものとして見せないため)。前の期間の失敗も引き継がない。
    // カテゴリは期間に依存しないため、値もエラーも保つ。
    _records = null;
    _recordsError = null;
    _summary = null;
    _recordsSubscription.cancel();
    _subscribeRecords();
    notifyListeners();
  }

  void _subscribeRecords() {
    _recordsSubscription = _recordRepository
        .watchPeriod(period)
        .listen(
          _onRecords,
          onError: (Object error, StackTrace stackTrace) => _onError(
            error,
            stackTrace,
            message: 'レコードの購読が失敗しました',
            assign: (exception) => _recordsError = exception,
          ),
        );
  }

  void _onCategories(List<ExpenseCategory> categories) {
    _categories = categories;
    // 後続のスナップショットで回復しうるため、正常な発行でエラーを解消する。
    // 解消するのは自分の購読のエラーだけ(他の購読の失敗はここでは回復していない)
    _categoriesError = null;
    _summarize();
  }

  void _onRecords(List<Record> records) {
    _records = records;
    _recordsError = null;
    _summarize();
  }

  void _summarize() {
    final categories = _categories;
    final records = _records;
    if (categories != null && records != null) {
      _summary = BudgetSummary.from(categories, records);
    }
    notifyListeners();
  }

  /// `Result.guard`と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  ///
  /// [assign]で失敗した購読自身のエラーフィールドだけを更新する
  /// (どの購読が失敗しているかを区別できないと、正常な発行での解消も
  /// 購読単位にできないため)。
  void _onError(
    Object error,
    StackTrace stackTrace, {
    required String message,
    required void Function(Exception) assign,
  }) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      message,
      name: 'BudgetViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
    assign(error);
    notifyListeners();
  }

  static Period _periodOf(BudgetPeriodMode mode, int year, int month) =>
      switch (mode) {
        BudgetPeriodMode.calendarMonth => Period.calendarMonth(year, month),
        BudgetPeriodMode.fiscalMonth => FiscalMonth(year, month).period,
      };

  /// [mode]で[today]が属する期間の年月。
  static (int, int) _currentYearMonth(BudgetPeriodMode mode, DateTime today) {
    switch (mode) {
      case BudgetPeriodMode.calendarMonth:
        return (today.year, today.month);
      case BudgetPeriodMode.fiscalMonth:
        final fiscalMonth = FiscalMonth.containing(today);
        return (fiscalMonth.year, fiscalMonth.month);
    }
  }

  // 状態を読むgetterではなく比較する年月を引数に取る純粋関数にする:
  // 「どの年月同士の比較か」が呼び出し側で明示される
  static bool _isBefore({
    required int year,
    required int month,
    required int otherYear,
    required int otherMonth,
  }) => year < otherYear || (year == otherYear && month < otherMonth);

  static DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  @override
  void dispose() {
    _categoriesSubscription.cancel();
    _recordsSubscription.cancel();
    super.dispose();
  }
}
