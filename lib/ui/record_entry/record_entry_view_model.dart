import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/category/category_repository.dart';
import '../../data/repositories/property/property_repository.dart';
import '../../data/repositories/record/record_repository.dart';
import '../../domain/models/amount.dart';
import '../../domain/models/category.dart';
import '../../domain/models/category_id.dart';
import '../../domain/models/property.dart';
import '../../domain/models/property_id.dart';
import '../../domain/models/record_content.dart';
import '../../domain/models/record_date.dart';
import '../../domain/models/record_note.dart';
import '../../utils/command.dart';
// utils/result.dartが独自の`Error<T>`(Resultの失敗variant)を公開しており、
// dart:coreの`Error`(Error.throwWithStackTrace)と名前が衝突する。このファイルは
// dart:core側のみ使うため、Resultの失敗variantを隠す。
import '../../utils/result.dart' hide Error;

/// 記録入力画面で選択できるレコードの種別。
enum RecordEntryType { income, expense, transfer }

/// 記録入力画面の状態を持つViewModel。
class RecordEntryViewModel extends ChangeNotifier {
  RecordEntryViewModel({
    required RecordRepository recordRepository,
    required CategoryRepository categoryRepository,
    required PropertyRepository propertyRepository,
    DateTime Function()? clock,
  }) : _recordRepository = recordRepository,
       _clock = clock ?? DateTime.now {
    _date = DateUtils.dateOnly(_clock());
    submitRecord = Command1(_submit);
    // 選択肢の購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態を扱う型であり、完了せず流れ
    // 続ける購読はその型に載らない。購読の結果はこのVMのフィールドで表す。
    _incomeCategoriesSubscription = categoryRepository
        .watchIncomeCategories()
        .listen(
          _onIncomeCategories,
          onError: (Object error, StackTrace stackTrace) => _onOptionsError(
            error,
            stackTrace,
            (exception) => _incomeCategoriesError = exception,
          ),
        );
    _expenseCategoriesSubscription = categoryRepository
        .watchExpenseCategories()
        .listen(
          _onExpenseCategories,
          onError: (Object error, StackTrace stackTrace) => _onOptionsError(
            error,
            stackTrace,
            (exception) => _expenseCategoriesError = exception,
          ),
        );
    _propertiesSubscription = propertyRepository.watchAll().listen(
      _onProperties,
      onError: (Object error, StackTrace stackTrace) => _onOptionsError(
        error,
        stackTrace,
        (exception) => _propertiesError = exception,
      ),
    );
  }

  final RecordRepository _recordRepository;

  // 「当日」を関数で受け取る理由:
  // 日付の上限は画面が開かれている間に日をまたいで変わりうるため、生成時の
  // 値を焼き付けず都度求める。テストからは固定値を返す関数を注入する。
  final DateTime Function() _clock;

  late final StreamSubscription<List<IncomeCategory>>
  _incomeCategoriesSubscription;
  late final StreamSubscription<List<ExpenseCategory>>
  _expenseCategoriesSubscription;
  late final StreamSubscription<List<Property>> _propertiesSubscription;

  /// 検証済みのレコードを保存するコマンド。
  ///
  /// 引数を検証済みの[RecordContent]に限ることで、検証漏れを型で防ぐ。検証は
  /// UI層の関心事として[submit]が担い、このコマンドの失敗はデータ層由来の
  /// 失敗だけを表す。
  late final Command1<void, RecordContent> submitRecord;

  List<IncomeCategory> _incomeCategories = const [];
  List<ExpenseCategory> _expenseCategories = const [];
  List<Property> _properties = const [];

  bool _hasReceivedIncomeCategories = false;
  bool _hasReceivedExpenseCategories = false;
  bool _hasReceivedProperties = false;

  /// 選択肢の初回読み込みが完了していないかどうか。
  ///
  /// 3本の購読すべての初回データが届くまでtrue。購読が失敗した場合はデータが
  /// 届かずtrueのままになるため、Viewは[optionsError]を先に確認すること。
  bool get isLoading =>
      !_hasReceivedIncomeCategories ||
      !_hasReceivedExpenseCategories ||
      !_hasReceivedProperties;

  // エラーは購読ごとに保持する。単一のフィールドで共有すると、失敗していない
  // 別の購読の正常データがエラーを消してしまい、失敗した購読の初回データは
  // 届かないままなので、画面がローディング表示に戻って抜け出せなくなる。
  Exception? _incomeCategoriesError;
  Exception? _expenseCategoriesError;
  Exception? _propertiesError;

  /// 選択肢の購読で発生した想定内の失敗。発生していなければ`null`。
  ///
  /// 3本の購読のうちどれか1本でも失敗していれば非null(選択肢が揃わないと
  /// 記録を入力できないため、部分的な失敗も画面全体のエラーとして扱う)。
  Exception? get optionsError =>
      _incomeCategoriesError ?? _expenseCategoriesError ?? _propertiesError;

  /// 選択できるカテゴリの一覧。振替はカテゴリを持たないため空。
  List<({CategoryId id, String name})> get categoryOptions => switch (_type) {
    RecordEntryType.income =>
      _incomeCategories
          .map((category) => (id: category.id, name: category.name.value))
          .toList(),
    RecordEntryType.expense =>
      _expenseCategories
          .map((category) => (id: category.id, name: category.name.value))
          .toList(),
    RecordEntryType.transfer => const [],
  };

  /// 選択できる資産の一覧。
  List<Property> get propertyOptions => _properties;

  RecordEntryType _type = RecordEntryType.income;

  /// 入力中のレコードの種別。
  RecordEntryType get type => _type;

  late DateTime _date;

  /// 入力中の日付。時刻は切り捨てて日付のみを保持する。
  DateTime get date => _date;

  /// 日付として選べる最も遅い日('当日')。
  ///
  /// 生成時に固定しない理由: この画面はタブのステートとして生き続けるため、
  /// 日をまたいだあとも古い「当日」が残っていると、その日の記録を入力できなく
  /// なってしまう。
  DateTime get maxSelectableDate => DateUtils.dateOnly(_clock());

  /// 日付として選べる最も早い日。
  ///
  /// 遡り入力に実用上の下限はないが、DatePickerは下限を要求するため十分に
  /// 過去の固定値を与える。
  DateTime get minSelectableDate => DateTime(2000);

  String _amountInput = '';

  /// 入力中の金額の文字列。
  String get amountInput => _amountInput;

  bool _hasAmountError = false;

  /// 入力中の金額が検証エラーかどうか。
  ///
  /// 空欄はまだ入力途中なのでエラー扱いしない(保存は[canSubmit]が止める)。
  /// エラーの文言はUIの関心事なのでここでは持たず、表示するWidgetが決める。
  bool get hasAmountError => _hasAmountError;

  String _noteInput = '';

  /// 入力中のメモ。
  String get noteInput => _noteInput;

  bool _hasNoteError = false;

  /// 入力中のメモが検証エラーかどうか。
  ///
  /// Viewの入力制限(TextFieldのmaxLength)は書記素クラスタ(見た目の文字数)で
  /// 数えるため、絵文字などでドメインの上限(UTF-16コード単位)を超えても
  /// 入力できてしまう。ドメインと同じ判定([RecordNote.isValid])でライブ検証し、
  /// 入力制限とドメイン制約の数え方の差を保存前に露見させる。
  /// エラーの文言はUIの関心事なのでここでは持たず、表示するWidgetが決める。
  bool get hasNoteError => _hasNoteError;

  bool _hasFutureDateError = false;

  /// 日付が未来日付で保存できない状態かどうか。
  ///
  /// 未来日付はDatePickerの選択範囲([maxSelectableDate])で防ぐため通常は
  /// 立たない。[submit]での防御検証に引っかかった場合だけ立ち、日付を選び直せば
  /// 解消する。
  bool get hasFutureDateError => _hasFutureDateError;

  CategoryId? _selectedCategoryId;

  /// 選択中のカテゴリ。未選択なら`null`。
  CategoryId? get selectedCategoryId => _selectedCategoryId;

  PropertyId? _selectedPropertyId;

  /// 選択中の資産(振替では振替元)。未選択なら`null`。
  PropertyId? get selectedPropertyId => _selectedPropertyId;

  PropertyId? _selectedToPropertyId;

  /// 選択中の振替先の資産。未選択なら`null`。
  PropertyId? get selectedToPropertyId => _selectedToPropertyId;

  /// 振替元と振替先に同じ資産が選ばれているかどうか。
  bool get hasSamePropertyError =>
      _type == RecordEntryType.transfer &&
      _selectedPropertyId != null &&
      _selectedPropertyId == _selectedToPropertyId;

  /// 入力内容を保存できるかどうか。
  bool get canSubmit =>
      !submitRecord.running &&
      _isAmountValid(_amountInput) &&
      !_hasNoteError &&
      !_hasFutureDateError &&
      _hasRequiredSelections;

  /// レコードの種別を切り替える。
  void selectType(RecordEntryType type) {
    if (_type == type) {
      return;
    }
    _type = type;
    // 収入と支出でカテゴリの一覧は別物なので、選択を持ち越さない。
    // 資産の一覧は種別によらず同じなので、資産の選択はそのまま残す。
    _selectedCategoryId = null;
    if (type != RecordEntryType.transfer) {
      _selectedToPropertyId = null;
    }
    notifyListeners();
  }

  /// 日付を選択する。時刻部分は切り捨てる。
  void selectDate(DateTime date) {
    _date = DateUtils.dateOnly(date);
    _hasFutureDateError = false;
    notifyListeners();
  }

  /// 入力中の金額が変化するたびにライブ検証を行う。
  ///
  /// 不正な入力になった時点でエラー表示と保存ボタンの無効化を行い、保存ボタンの
  /// 押下を待たずに気づけるようにする。毎キーストロークで無駄な再描画が
  /// 起きないよう、表示に影響する判定(エラー表示・保存可否)が変わったときだけ
  /// 通知する。
  void onAmountChanged(String input) {
    final hadError = _hasAmountError;
    final wasValid = _isAmountValid(_amountInput);
    final isValid = _isAmountValid(input);

    _amountInput = input;
    _hasAmountError = input.isNotEmpty && !isValid;

    if (_hasAmountError != hadError || isValid != wasValid) {
      notifyListeners();
    }
  }

  /// 入力中のメモが変化するたびにライブ検証を行う。
  ///
  /// 空文字は旧実装同様に許容する。毎キーストロークで無駄な再描画が起きないよう、
  /// 判定結果が変わったときだけ通知する([onAmountChanged]と同じ方針)。
  void onNoteChanged(String input) {
    final hadError = _hasNoteError;
    _noteInput = input;
    _hasNoteError = !RecordNote.isValid(input);
    if (_hasNoteError != hadError) {
      notifyListeners();
    }
  }

  /// カテゴリを選択する。
  void selectCategory(CategoryId? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// 資産(振替では振替元)を選択する。
  void selectProperty(PropertyId? propertyId) {
    _selectedPropertyId = propertyId;
    notifyListeners();
  }

  /// 振替先の資産を選択する。
  void selectToProperty(PropertyId? propertyId) {
    _selectedToPropertyId = propertyId;
    notifyListeners();
  }

  /// 入力内容を検証し、妥当ならレコードを保存する。
  ///
  /// 各検証はライブ検証やDatePickerの制限が主経路だが、型境界([submitRecord]が
  /// 受け取る[RecordContent])に不正な値を渡さないための防御としてここでも行う。
  Future<void> submit() async {
    if (_date.isAfter(maxSelectableDate)) {
      // 未来日付のレコードは資産残高と予算の見通しを壊すため、入力境界で拒否する
      _hasFutureDateError = true;
      notifyListeners();
      return;
    }
    if (hasSamePropertyError) {
      return;
    }

    final Amount amount;
    try {
      amount = Amount(int.parse(_amountInput));
    } on FormatException {
      _hasAmountError = true;
      notifyListeners();
      return;
    }

    final RecordNote note;
    try {
      note = RecordNote(_noteInput);
    } on FormatException {
      _hasNoteError = true;
      notifyListeners();
      return;
    }

    final recordDate = RecordDate(_date);
    final categoryId = _selectedCategoryId;
    final propertyId = _selectedPropertyId;
    final toPropertyId = _selectedToPropertyId;

    // 必須選択の欠落は[canSubmit]がボタンを無効化して防ぐが、
    // [RecordContent]へnullを渡さないための防御としてここでも確認する
    final RecordContent record;
    switch (_type) {
      case RecordEntryType.income:
        if (categoryId == null || propertyId == null) {
          return;
        }
        record = RecordContent.income(
          date: recordDate,
          amount: amount,
          note: note,
          categoryId: categoryId,
          propertyId: propertyId,
        );
      case RecordEntryType.expense:
        if (categoryId == null || propertyId == null) {
          return;
        }
        record = RecordContent.expense(
          date: recordDate,
          amount: amount,
          note: note,
          categoryId: categoryId,
          propertyId: propertyId,
        );
      case RecordEntryType.transfer:
        if (propertyId == null || toPropertyId == null) {
          return;
        }
        record = RecordContent.transfer(
          date: recordDate,
          amount: amount,
          note: note,
          fromPropertyId: propertyId,
          toPropertyId: toPropertyId,
        );
    }

    await submitRecord.execute(record);
  }

  // VMの状態を読むgetterではなく入力を引数に取る純粋関数にする:
  // 「どの入力に対する判定か」が呼び出し側で明示され、変更前後の入力への
  // 判定([onAmountChanged])を同じ関数で表せる
  static bool _isAmountValid(String amountInput) {
    final parsed = int.tryParse(amountInput);
    return parsed != null && Amount.isValid(parsed);
  }

  bool get _hasRequiredSelections => switch (_type) {
    RecordEntryType.income || RecordEntryType.expense =>
      _selectedCategoryId != null && _selectedPropertyId != null,
    RecordEntryType.transfer =>
      _selectedPropertyId != null &&
          _selectedToPropertyId != null &&
          !hasSamePropertyError,
  };

  void _onIncomeCategories(List<IncomeCategory> categories) {
    _incomeCategories = categories;
    _hasReceivedIncomeCategories = true;
    // 後続のスナップショットで回復しうるため、正常な発行でエラーを解消する。
    // 解消するのは自分の購読のエラーだけ(他の購読の失敗はここでは回復していない)
    _incomeCategoriesError = null;
    _onOptionsReceived();
  }

  void _onExpenseCategories(List<ExpenseCategory> categories) {
    _expenseCategories = categories;
    _hasReceivedExpenseCategories = true;
    _expenseCategoriesError = null;
    _onOptionsReceived();
  }

  void _onProperties(List<Property> properties) {
    _properties = properties;
    _hasReceivedProperties = true;
    _propertiesError = null;
    _onOptionsReceived();
  }

  void _onOptionsReceived() {
    _pruneSelections();
    notifyListeners();
  }

  /// 選択中のIDが最新の選択肢に無ければ選択を解除する。
  ///
  /// ペア相手がカテゴリや資産を削除すると、選択済みのIDが選択肢から消える。
  /// 選択を残したままだとドロップダウンが一覧に無い値を指した不整合な状態に
  /// なるため、ここで解除して選び直させる。
  void _pruneSelections() {
    final categoryId = _selectedCategoryId;
    if (categoryId != null &&
        !categoryOptions.any((option) => option.id == categoryId)) {
      _selectedCategoryId = null;
    }

    final propertyIds = _properties.map((property) => property.id).toSet();
    if (_selectedPropertyId != null &&
        !propertyIds.contains(_selectedPropertyId)) {
      _selectedPropertyId = null;
    }
    if (_selectedToPropertyId != null &&
        !propertyIds.contains(_selectedToPropertyId)) {
      _selectedToPropertyId = null;
    }
  }

  /// [Result.guard]と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  ///
  /// [assign]で失敗した購読自身のエラーフィールドだけを更新する
  /// (どの購読が失敗しているかを区別できないと、正常な発行での解消も
  /// 購読単位にできないため)。
  void _onOptionsError(
    Object error,
    StackTrace stackTrace,
    void Function(Exception) assign,
  ) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      '選択肢(カテゴリ・資産)の購読が失敗しました',
      name: 'RecordEntryViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
    assign(error);
    notifyListeners();
  }

  Future<Result<void>> _submit(RecordContent record) async {
    final result = await _recordRepository.add(record);
    // dispose後は何もしない: ノート切替はHostごと再生成でこのVMをdisposeするが、
    // 保存中のCommandはVMのライフサイクルから独立して完走する。破棄済みの
    // ChangeNotifierへの通知はassert違反になる(レコード自体は切替前のノートへ
    // 正しく書き込まれている)
    if (result is Ok<void> && !_disposed) {
      // 続けて記録を入力できるよう、レコードごとに変わる金額とメモだけ空にする
      // (日付・種別・カテゴリ・資産は次の記録でも同じことが多いため保持する。
      // 旧UIのForm.reset()と同じ範囲)
      _amountInput = '';
      _noteInput = '';
      notifyListeners();
    }
    return result;
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _incomeCategoriesSubscription.cancel();
    _expenseCategoriesSubscription.cancel();
    _propertiesSubscription.cancel();
    super.dispose();
  }
}
