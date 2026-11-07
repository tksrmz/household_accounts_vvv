import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/category/category_repository.dart';
import '../../domain/models/category.dart';
import '../../domain/models/category_id.dart';
import '../../utils/command.dart';

/// カテゴリ一覧画面の状態を持つViewModel。
///
/// 収入カテゴリと支出カテゴリは別々に購読し、読み込み中・エラー・一覧の状態も
/// 種別ごとに独立して持つ。片方の種別に不正なデータがあっても、もう片方の
/// 一覧は見えるようにするため(旧画面も種別ごとに別の状態を持っていた)。
class CategoriesViewModel extends ChangeNotifier {
  CategoriesViewModel({required CategoryRepository categoryRepository}) {
    deleteIncome = Command1(categoryRepository.deleteIncomeCategory);
    deleteExpense = Command1(categoryRepository.deleteExpenseCategory);
    // カテゴリの購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態を扱う型であり、完了せず流れ
    // 続ける購読はその型に載らない。購読の結果はこのVMのフィールドで表す。
    _income = _CategorySection(
      label: '収入カテゴリ',
      stream: categoryRepository.watchIncomeCategories(),
      onChanged: notifyListeners,
    );
    _expense = _CategorySection(
      label: '支出カテゴリ',
      stream: categoryRepository.watchExpenseCategories(),
      onChanged: notifyListeners,
    );
  }

  late final _CategorySection<IncomeCategory> _income;
  late final _CategorySection<ExpenseCategory> _expense;

  /// 収入カテゴリを削除するコマンド。
  ///
  /// 削除の成功で一覧を更新する必要はない(カテゴリの購読が削除を反映する)。
  /// 削除してよいかの確認はUIの関心事なのでViewが行い、このコマンドは確認済みの
  /// 削除だけを受け取る。このコマンドの失敗はデータ層由来の失敗だけを表す。
  late final Command1<void, CategoryId> deleteIncome;

  /// 支出カテゴリを削除するコマンド。考え方は[deleteIncome]と同じ。
  late final Command1<void, CategoryId> deleteExpense;

  /// 表示する収入カテゴリの一覧。並びはRepositoryの契約(名前の昇順)に従う。
  List<IncomeCategory> get incomeCategories => _income.categories;

  /// 収入カテゴリの初回の読み込みが完了していないかどうか。
  ///
  /// 購読が失敗した場合はデータが届かずtrueのままになるため、Viewは
  /// [incomeLoadError]を先に確認すること。
  bool get isIncomeLoading => _income.isLoading;

  /// 収入カテゴリの購読で発生した想定内の失敗。発生していなければ`null`。
  Exception? get incomeLoadError => _income.loadError;

  /// 表示する支出カテゴリの一覧。並びはRepositoryの契約(名前の昇順)に従う。
  List<ExpenseCategory> get expenseCategories => _expense.categories;

  /// 支出カテゴリの初回の読み込みが完了していないかどうか。考え方は
  /// [isIncomeLoading]と同じ。
  bool get isExpenseLoading => _expense.isLoading;

  /// 支出カテゴリの購読で発生した想定内の失敗。発生していなければ`null`。
  Exception? get expenseLoadError => _expense.loadError;

  @override
  void dispose() {
    _income.cancel();
    _expense.cancel();
    super.dispose();
  }
}

/// 1種別ぶんのカテゴリの購読と、その結果(読み込み中・エラー・一覧)。
///
/// 収入と支出で同じ状態遷移を2回書かないためにまとめる。
class _CategorySection<T> {
  _CategorySection({
    required String label,
    required Stream<List<T>> stream,
    required VoidCallback onChanged,
  }) : _label = label,
       _onChanged = onChanged {
    _subscription = stream.listen(_onCategories, onError: _onError);
  }

  /// ログに出す種別の名前。
  final String _label;
  final VoidCallback _onChanged;
  late final StreamSubscription<List<T>> _subscription;

  List<T> categories = const [];

  bool _hasReceived = false;

  bool get isLoading => !_hasReceived;

  Exception? loadError;

  void _onCategories(List<T> categories) {
    this.categories = categories;
    _hasReceived = true;
    // 後続のスナップショットで回復しうるため、正常な発行でエラーを解消する
    loadError = null;
    _onChanged();
  }

  /// [Result.guard]と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  void _onError(Object error, StackTrace stackTrace) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      '$_labelの購読が失敗しました',
      name: 'CategoriesViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
    loadError = error;
    _onChanged();
  }

  void cancel() => _subscription.cancel();
}
