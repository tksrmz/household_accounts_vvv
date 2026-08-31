import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/category/category_repository.dart';
import '../../data/repositories/property/property_repository.dart';
import '../../data/repositories/record/record_repository.dart';
import '../../domain/models/category.dart';
import '../../domain/models/category_id.dart';
import '../../domain/models/period.dart';
import '../../domain/models/property.dart';
import '../../domain/models/property_id.dart';
import '../../domain/models/record.dart';
import '../../utils/command.dart';

/// 日次明細画面の状態を持つViewModel。
class DailyRecordsViewModel extends ChangeNotifier {
  DailyRecordsViewModel({
    required RecordRepository recordRepository,
    required CategoryRepository categoryRepository,
    required PropertyRepository propertyRepository,
    required int year,
    required int month,
    required int day,
  }) : _year = year,
       _month = month,
       _day = day {
    deleteRecord = Command1(recordRepository.delete);
    // レコードと名前解決の購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態を扱う型であり、完了せず流れ
    // 続ける購読はその型に載らない。購読の結果はこのVMのフィールドで表す。
    _recordsSubscription = recordRepository
        .watchPeriod(Period.day(year, month, day))
        .listen(
          _onRecords,
          onError: (Object error, StackTrace stackTrace) =>
              _onSourceError(error, stackTrace, (exception) {
                _recordsError = exception;
              }),
        );
    _incomeCategoriesSubscription = categoryRepository
        .watchIncomeCategories()
        .listen(
          _onIncomeCategories,
          onError: (Object error, StackTrace stackTrace) =>
              _onSourceError(error, stackTrace, (exception) {
                _incomeCategoriesError = exception;
              }),
        );
    _expenseCategoriesSubscription = categoryRepository
        .watchExpenseCategories()
        .listen(
          _onExpenseCategories,
          onError: (Object error, StackTrace stackTrace) =>
              _onSourceError(error, stackTrace, (exception) {
                _expenseCategoriesError = exception;
              }),
        );
    _propertiesSubscription = propertyRepository.watchAll().listen(
      _onProperties,
      onError: (Object error, StackTrace stackTrace) =>
          _onSourceError(error, stackTrace, (exception) {
            _propertiesError = exception;
          }),
    );
  }

  final int _year;

  /// 表示中の日付の年。
  int get year => _year;

  final int _month;

  /// 表示中の日付の月(1〜12)。
  int get month => _month;

  final int _day;

  /// 表示中の日付の日。
  int get day => _day;

  late final StreamSubscription<List<Record>> _recordsSubscription;
  late final StreamSubscription<List<IncomeCategory>>
  _incomeCategoriesSubscription;
  late final StreamSubscription<List<ExpenseCategory>>
  _expenseCategoriesSubscription;
  late final StreamSubscription<List<Property>> _propertiesSubscription;

  /// レコードを削除するコマンド。
  ///
  /// 削除の成功で一覧を更新する必要はない(レコードの購読が削除を反映する)。
  /// このコマンドの失敗はデータ層由来の失敗だけを表す。
  late final Command1<void, Record> deleteRecord;

  List<Record> _records = const [];

  /// 表示する日のレコード。日時の昇順、同じ日時ではレコードIDの昇順に並ぶ。
  List<Record> get records => _records;

  Map<CategoryId, String> _incomeCategoryNames = const {};
  Map<CategoryId, String> _expenseCategoryNames = const {};
  Map<PropertyId, String> _propertyNames = const {};

  bool _hasReceivedRecords = false;
  bool _hasReceivedIncomeCategories = false;
  bool _hasReceivedExpenseCategories = false;
  bool _hasReceivedProperties = false;

  /// 初回の読み込みが完了していないかどうか。
  ///
  /// 4本の購読すべての初回データが届くまでtrue。レコードだけ先に届いても、
  /// 名前が引けない一覧を見せることになるため読み込み中として扱う。購読が
  /// 失敗した場合はデータが届かずtrueのままになるため、Viewは[loadError]を
  /// 先に確認すること。
  bool get isLoading =>
      !_hasReceivedRecords ||
      !_hasReceivedIncomeCategories ||
      !_hasReceivedExpenseCategories ||
      !_hasReceivedProperties;

  // エラーは購読ごとに保持する。単一のフィールドで共有すると、失敗していない
  // 別の購読の正常データがエラーを消してしまい、失敗した購読の初回データは
  // 届かないままなので、画面がローディング表示に戻って抜け出せなくなる。
  Exception? _recordsError;
  Exception? _incomeCategoriesError;
  Exception? _expenseCategoriesError;
  Exception? _propertiesError;

  /// 購読で発生した想定内の失敗。発生していなければ`null`。
  ///
  /// 4本の購読のうちどれか1本でも失敗していれば非null(名前を引けないと明細を
  /// 表示できないため、部分的な失敗も画面全体のエラーとして扱う)。
  Exception? get loadError =>
      _recordsError ??
      _incomeCategoriesError ??
      _expenseCategoriesError ??
      _propertiesError;

  /// [id]の収入カテゴリの名前。参照先が存在しなければ`null`。
  ///
  /// 収入と支出でカテゴリを分けて引くのは、両者が別コレクションでありIDの
  /// 一意性もコレクションごとだからである(混ぜて引くと、別種のカテゴリの名前を
  /// 引き当てうる)。参照先が無い場合の表示文言はUIの関心事なのでここでは持たず、
  /// 表示するWidgetが決める。
  String? incomeCategoryNameOf(CategoryId id) => _incomeCategoryNames[id];

  /// [id]の支出カテゴリの名前。参照先が存在しなければ`null`。
  String? expenseCategoryNameOf(CategoryId id) => _expenseCategoryNames[id];

  /// [id]の資産の名前。参照先が存在しなければ`null`。
  String? propertyNameOf(PropertyId id) => _propertyNames[id];

  void _onRecords(List<Record> records) {
    _records = _sortedByDateThenId(records);
    _hasReceivedRecords = true;
    // 後続のスナップショットで回復しうるため、正常な発行でエラーを解消する。
    // 解消するのは自分の購読のエラーだけ(他の購読の失敗はここでは回復していない)
    _recordsError = null;
    notifyListeners();
  }

  void _onIncomeCategories(List<IncomeCategory> categories) {
    _incomeCategoryNames = {
      for (final category in categories) category.id: category.name.value,
    };
    _hasReceivedIncomeCategories = true;
    _incomeCategoriesError = null;
    notifyListeners();
  }

  void _onExpenseCategories(List<ExpenseCategory> categories) {
    _expenseCategoryNames = {
      for (final category in categories) category.id: category.name.value,
    };
    _hasReceivedExpenseCategories = true;
    _expenseCategoriesError = null;
    notifyListeners();
  }

  void _onProperties(List<Property> properties) {
    _propertyNames = {
      for (final property in properties) property.id: property.name.value,
    };
    _hasReceivedProperties = true;
    _propertiesError = null;
    notifyListeners();
  }

  // 状態を読むgetterではなく並べ替える一覧を引数に取る純粋関数にする:
  // 「どの一覧を並べ替えた結果か」が呼び出し側で明示される。
  //
  // レコードIDを二次キーにするのは、同じ日時のレコードの順序をスナップショットの
  // 到着順に委ねないためである(Repositoryは同一日時内の順序を規定せず、Dartの
  // sortも安定ではないため、二次キーが無いと同じデータでも並びが揺れうる)。
  static List<Record> _sortedByDateThenId(List<Record> records) {
    final sorted = [...records];
    sorted.sort((one, other) {
      final byDate = one.date.value.compareTo(other.date.value);
      return byDate != 0 ? byDate : one.id.value.compareTo(other.id.value);
    });
    return sorted;
  }

  /// [Result.guard]と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  ///
  /// [assign]で失敗した購読自身のエラーフィールドだけを更新する
  /// (どの購読が失敗しているかを区別できないと、正常な発行での解消も
  /// 購読単位にできないため)。
  void _onSourceError(
    Object error,
    StackTrace stackTrace,
    void Function(Exception) assign,
  ) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      '日次明細の購読が失敗しました',
      name: 'DailyRecordsViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
    assign(error);
    notifyListeners();
  }

  @override
  void dispose() {
    _recordsSubscription.cancel();
    _incomeCategoriesSubscription.cancel();
    _expenseCategoriesSubscription.cancel();
    _propertiesSubscription.cancel();
    super.dispose();
  }
}
