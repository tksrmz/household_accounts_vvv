import 'package:flutter/foundation.dart';

import '../../data/repositories/property/property_repository.dart';
import '../../domain/models/property.dart';
import '../../domain/models/property_name.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// 資産エディタ画面(追加・編集)の状態を持つViewModel。
class PropertyEditorViewModel extends ChangeNotifier {
  /// [property]を渡すとその資産の編集、`null`なら資産の追加になる。
  PropertyEditorViewModel({
    required PropertyRepository propertyRepository,
    Property? property,
  }) : _propertyRepository = propertyRepository,
       _initial = property,
       _nameInput = property?.name.value ?? '',
       _balanceInput = property?.balance.toString() ?? '' {
    save = Command1(_save);
  }

  final PropertyRepository _propertyRepository;

  /// 編集対象の資産の、エディタを開いた時点の内容。追加では`null`。
  final Property? _initial;

  /// 検証済みの資産名と残高を保存するコマンド。
  ///
  /// 引数を検証済みの型に限ることで、検証漏れを型で防ぐ。検証はUI層の関心事として
  /// [submit]が担い、このコマンドの失敗はデータ層由来の失敗だけを表す。
  late final Command1<void, ({PropertyName name, int balance})> save;

  /// 資産の編集かどうか(falseなら追加)。
  bool get isEditing => _initial != null;

  String _nameInput;

  /// 入力中の資産名。編集では編集対象の資産名から始まる。
  String get nameInput => _nameInput;

  String _balanceInput;

  /// 入力中の残高の文字列。編集では編集対象の残高から始まる。
  String get balanceInput => _balanceInput;

  bool _hasNameError = false;

  /// 入力中の資産名が検証エラーかどうか。
  ///
  /// 追加画面を開いた直後の空欄はまだ何も入力していないのでエラー扱いしない
  /// (保存は[canSave]が止める)。一度入力したあとに空へ戻した場合は、保存できない
  /// 理由を示すためにエラーとする。エラーの文言はUIの関心事なのでここでは持たず、
  /// 表示するWidgetが決める。
  bool get hasNameError => _hasNameError;

  bool _hasBalanceError = false;

  /// 入力中の残高が検証エラーかどうか。考え方は[hasNameError]と同じ。
  bool get hasBalanceError => _hasBalanceError;

  /// 入力内容を保存できるかどうか。
  bool get canSave =>
      !save.running &&
      _isNameValid(_nameInput) &&
      _isBalanceValid(_balanceInput);

  /// 入力中の資産名が変化するたびにライブ検証を行う。
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

  /// 入力中の残高が変化するたびにライブ検証を行う。方針は[onNameChanged]と同じ。
  void onBalanceChanged(String input) {
    final hadError = _hasBalanceError;
    final couldSave = canSave;
    _balanceInput = input;
    _hasBalanceError = !_isBalanceValid(input);
    if (_hasBalanceError != hadError || canSave != couldSave) {
      notifyListeners();
    }
  }

  /// 入力内容を検証し、妥当なら保存する。
  ///
  /// ライブ検証が主経路だが、型境界([save]の引数)に不正な値を渡さないための
  /// 防御としてここでも検証する。
  Future<void> submit() async {
    final PropertyName name;
    try {
      name = PropertyName(_nameInput);
    } on FormatException {
      _hasNameError = true;
      notifyListeners();
      return;
    }

    final balance = _parseBalance(_balanceInput);
    if (balance == null) {
      _hasBalanceError = true;
      notifyListeners();
      return;
    }

    await save.execute((name: name, balance: balance));
  }

  // VMの状態を読むgetterではなく入力を引数に取る純粋関数にする:
  // 「どの入力に対する判定か」が呼び出し側で明示される
  static bool _isNameValid(String nameInput) => PropertyName.isValid(nameInput);

  static bool _isBalanceValid(String balanceInput) =>
      _parseBalance(balanceInput) != null;

  /// [balanceInput]を残高として解釈する。整数として読めなければ`null`。
  ///
  /// 残高は支出で負になりうるため、負の整数も許容する。int.tryParseだけに頼らず
  /// 書式を先に確かめるのは、int.tryParseが前後の空白や`0x`始まりの16進表記まで
  /// 受け付けてしまい、画面に見えている文字列と保存される値が食い違うため。
  static int? _parseBalance(String balanceInput) {
    if (!_balancePattern.hasMatch(balanceInput)) {
      return null;
    }
    // 書式が正しくても、intの範囲を超える桁数ならnullになる
    return int.tryParse(balanceInput, radix: 10);
  }

  static final _balancePattern = RegExp(r'^-?[0-9]+$');

  Future<Result<void>> _save(({PropertyName name, int balance}) input) {
    final initial = _initial;
    if (initial == null) {
      return _propertyRepository.add(name: input.name, balance: input.balance);
    }

    // 変わったフィールドだけを書く。残高を変えていないのに書き戻すと、エディタを
    // 開いている間に入った残高の増減(記録の入力やペア相手の操作によるもの)を、
    // 開いた時点の残高で上書きしてしまうため
    final name = input.name == initial.name ? null : input.name;
    final balance = input.balance == initial.balance ? null : input.balance;
    if (name == null && balance == null) {
      // 書き込むものがない。保存を押した利用者の意図(編集を終える)は満たされて
      // いるため、失敗ではなく成功として扱う
      return Future.value(const Result.ok(null));
    }
    return _propertyRepository.update(initial.id, name: name, balance: balance);
  }
}
