import 'package:flutter/foundation.dart';

import '../../data/repositories/category/category_repository.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';
import '../../domain/models/category_name.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// エディタで選ぶカテゴリの種別。
///
/// 画面の切り替えボタン(収入/支出)の状態を表すUI層の型。ドメインの
/// [IncomeCategory]/[ExpenseCategory]は型そのものが種別を表すため、
/// ドメイン側にこの列挙型は置かない。
enum CategoryKind { income, expense }

/// 検証済みの入力。[CategoryEditorViewModel.save]が受け取る。
///
/// 収入カテゴリは名前だけ、支出カテゴリは名前と予算を持つため、種別ごとに
/// 型を分ける(予算を持たない収入カテゴリへ予算を渡す経路を型で塞ぐ)。
sealed class ValidatedCategoryInput {
  const ValidatedCategoryInput({required this.name});

  final CategoryName name;
}

/// 検証済みの収入カテゴリの入力。
final class ValidatedIncomeCategoryInput extends ValidatedCategoryInput {
  const ValidatedIncomeCategoryInput({required super.name});
}

/// 検証済みの支出カテゴリの入力。
final class ValidatedExpenseCategoryInput extends ValidatedCategoryInput {
  const ValidatedExpenseCategoryInput({
    required super.name,
    required this.budget,
  });

  final Budget budget;
}

/// カテゴリエディタ画面(追加・編集)の状態を持つViewModel。
///
/// 追加・収入カテゴリの編集・支出カテゴリの編集の3つを名前付きコンストラクタで
/// 作り分ける。収入カテゴリと支出カテゴリには共通の上位型がないため、
/// 「編集対象のカテゴリ」を1つの引数で受けずに、種別ごとに入口を分ける。
class CategoryEditorViewModel extends ChangeNotifier {
  /// カテゴリの追加。種別は収入から始まり、切り替えられる。
  CategoryEditorViewModel.add({required CategoryRepository categoryRepository})
    : this._(
        categoryRepository,
        kind: CategoryKind.income,
        nameInput: '',
        budgetInput: '',
      );

  /// 収入カテゴリ[category]の編集。種別は切り替えられない。
  CategoryEditorViewModel.editIncome({
    required CategoryRepository categoryRepository,
    required IncomeCategory category,
  }) : this._(
         categoryRepository,
         kind: CategoryKind.income,
         nameInput: category.name.value,
         budgetInput: '',
         initialIncome: category,
       );

  /// 支出カテゴリ[category]の編集。種別は切り替えられない。
  CategoryEditorViewModel.editExpense({
    required CategoryRepository categoryRepository,
    required ExpenseCategory category,
  }) : this._(
         categoryRepository,
         kind: CategoryKind.expense,
         nameInput: category.name.value,
         budgetInput: category.budget.value.toString(),
         initialExpense: category,
       );

  CategoryEditorViewModel._(
    this._categoryRepository, {
    required CategoryKind kind,
    required String nameInput,
    required String budgetInput,
    IncomeCategory? initialIncome,
    ExpenseCategory? initialExpense,
  }) : _kind = kind,
       _nameInput = nameInput,
       _budgetInput = budgetInput,
       _initialIncome = initialIncome,
       _initialExpense = initialExpense {
    save = Command1(_save);
  }

  final CategoryRepository _categoryRepository;

  /// 編集対象の収入カテゴリの、エディタを開いた時点の内容。それ以外では`null`。
  final IncomeCategory? _initialIncome;

  /// 編集対象の支出カテゴリの、エディタを開いた時点の内容。それ以外では`null`。
  final ExpenseCategory? _initialExpense;

  /// 検証済みの入力を保存するコマンド。
  ///
  /// 引数を検証済みの型に限ることで、検証漏れを型で防ぐ。検証はUI層の関心事として
  /// [submit]が担い、このコマンドの失敗はデータ層由来の失敗だけを表す。
  late final Command1<void, ValidatedCategoryInput> save;

  /// カテゴリの編集かどうか(falseなら追加)。
  bool get isEditing => _initialIncome != null || _initialExpense != null;

  /// 種別を切り替えられるかどうか。
  ///
  /// 追加のときだけ切り替えられる。保存済みのカテゴリは収入と支出で別の
  /// コレクションに置かれるため、編集で種別を変えることはできない。
  bool get canChangeKind => !isEditing;

  CategoryKind _kind;

  /// 選択中の種別。
  CategoryKind get kind => _kind;

  String _nameInput;

  /// 入力中のカテゴリ名。編集では編集対象のカテゴリ名から始まる。
  String get nameInput => _nameInput;

  String _budgetInput;

  /// 入力中の予算の文字列。支出カテゴリの編集では編集対象の予算から始まる。
  String get budgetInput => _budgetInput;

  bool _hasNameError = false;

  /// 入力中のカテゴリ名が検証エラーかどうか。
  ///
  /// 追加画面を開いた直後の空欄はまだ何も入力していないのでエラー扱いしない
  /// (保存は[canSave]が止める)。一度入力したあとに空へ戻した場合は、保存できない
  /// 理由を示すためにエラーとする。エラーの文言はUIの関心事なのでここでは持たず、
  /// 表示するWidgetが決める。
  bool get hasNameError => _hasNameError;

  bool _hasBudgetError = false;

  /// 入力中の予算が検証エラーかどうか。考え方は[hasNameError]と同じ。
  ///
  /// 予算の入力欄は支出を選んでいるときだけ表示されるため、Viewは支出を
  /// 選んでいるときだけこのエラーを表示すること。
  bool get hasBudgetError => _hasBudgetError;

  /// 入力内容を保存できるかどうか。
  ///
  /// 予算は支出カテゴリだけが持つため、収入を選んでいるときは予算の入力を見ない。
  bool get canSave =>
      !save.running &&
      _isNameValid(_nameInput) &&
      (_kind == CategoryKind.income || _isBudgetValid(_budgetInput));

  /// 種別を[kind]へ切り替える。
  ///
  /// 編集のときは何もしない(切り替えボタンは表示し続けるが、押しても変わらない。
  /// ボタンを無効表示にすると、どちらの種別を編集しているのか読み取りにくくなるため)。
  /// 予算の入力は消さない。収入を選んでいる間は予算を保存しないので、消す必要がなく、
  /// 支出へ戻したときに入力し直さなくて済む。
  void onKindSelected(CategoryKind kind) {
    if (!canChangeKind || kind == _kind) {
      return;
    }
    _kind = kind;
    notifyListeners();
  }

  /// 入力中のカテゴリ名が変化するたびにライブ検証を行う。
  ///
  /// 不正な入力になった時点でエラー表示と保存ボタンの無効化を行い、保存ボタンの
  /// 押下を待たずに気づけるようにする。Viewの入力制限(TextFieldのmaxLength)は
  /// 書記素クラスタ(見た目の文字数)で数えるため、絵文字などでドメインの上限
  /// (UTF-16コード単位)を超えても入力できてしまう。その差もここで露見させる。
  /// 毎キーストロークで無駄な再描画が起きないよう、表示に影響する判定(エラー
  /// 表示・保存可否)が変わったときだけ通知する。エラー表示だけを見ると、追加画面の
  /// 未入力(エラーなし・保存不可)から妥当な入力(エラーなし・保存可)への変化を
  /// 取りこぼすため、保存可否も比べる。
  void onNameChanged(String input) {
    final hadError = _hasNameError;
    final couldSave = canSave;
    _nameInput = input;
    _hasNameError = !_isNameValid(input);
    if (_hasNameError != hadError || canSave != couldSave) {
      notifyListeners();
    }
  }

  /// 入力中の予算が変化するたびにライブ検証を行う。方針は[onNameChanged]と同じ。
  void onBudgetChanged(String input) {
    final hadError = _hasBudgetError;
    final couldSave = canSave;
    _budgetInput = input;
    _hasBudgetError = !_isBudgetValid(input);
    if (_hasBudgetError != hadError || canSave != couldSave) {
      notifyListeners();
    }
  }

  /// 入力内容を検証し、妥当なら保存する。
  ///
  /// ライブ検証が主経路だが、型境界([save]の引数)に不正な値を渡さないための
  /// 防御としてここでも検証する。
  Future<void> submit() async {
    final CategoryName name;
    try {
      name = CategoryName(_nameInput);
    } on FormatException {
      _hasNameError = true;
      notifyListeners();
      return;
    }

    final ValidatedCategoryInput input;
    switch (_kind) {
      case CategoryKind.income:
        input = ValidatedIncomeCategoryInput(name: name);
      case CategoryKind.expense:
        final budget = _parseBudget(_budgetInput);
        if (budget == null) {
          _hasBudgetError = true;
          notifyListeners();
          return;
        }
        input = ValidatedExpenseCategoryInput(
          name: name,
          budget: Budget(budget),
        );
    }

    await save.execute(input);
  }

  // VMの状態を読むgetterではなく入力を引数に取る純粋関数にする:
  // 「どの入力に対する判定か」が呼び出し側で明示される
  static bool _isNameValid(String nameInput) => CategoryName.isValid(nameInput);

  static bool _isBudgetValid(String budgetInput) =>
      _parseBudget(budgetInput) != null;

  /// [budgetInput]を予算として解釈する。0以上の整数として読めなければ`null`。
  ///
  /// int.tryParseだけに頼らず書式を先に確かめるのは、int.tryParseが前後の空白・
  /// 符号・`0x`始まりの16進表記まで受け付けてしまい、画面に見えている文字列と
  /// 保存される値が食い違うため。予算は0以上なので符号は許さない(書式で負数を
  /// 弾くため、ここで読めた値は[Budget]の検証も満たす)。
  static int? _parseBudget(String budgetInput) {
    if (!_budgetPattern.hasMatch(budgetInput)) {
      return null;
    }
    // 書式が正しくても、intの範囲を超える桁数ならnullになる
    return int.tryParse(budgetInput, radix: 10);
  }

  static final _budgetPattern = RegExp(r'^[0-9]+$');

  Future<Result<void>> _save(ValidatedCategoryInput input) {
    switch (input) {
      case ValidatedIncomeCategoryInput(:final name):
        final initial = _initialIncome;
        if (initial == null) {
          return _categoryRepository.addIncomeCategory(name);
        }
        if (name == initial.name) {
          return _noChanges();
        }
        return _categoryRepository.updateIncomeCategory(initial.id, name: name);

      case ValidatedExpenseCategoryInput(:final name, :final budget):
        final initial = _initialExpense;
        if (initial == null) {
          return _categoryRepository.addExpenseCategory(
            name: name,
            budget: budget,
          );
        }
        // 変わったフィールドだけを書く。変えていないフィールドまで書き戻すと、
        // エディタを開いている間に他の端末やペア相手が行った変更を、開いた時点の
        // 値で上書きしてしまうため
        final changedName = name == initial.name ? null : name;
        final changedBudget = budget == initial.budget ? null : budget;
        if (changedName == null && changedBudget == null) {
          return _noChanges();
        }
        return _categoryRepository.updateExpenseCategory(
          initial.id,
          name: changedName,
          budget: changedBudget,
        );
    }
  }

  /// 書き込むものがないときの結果。保存を押した利用者の意図(編集を終える)は
  /// 満たされているため、失敗ではなく成功として扱う。
  static Future<Result<void>> _noChanges() =>
      Future.value(const Result.ok(null));
}
