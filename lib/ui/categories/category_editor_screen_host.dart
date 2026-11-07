import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/category.dart';
import 'category_editor_screen.dart';
import 'category_editor_view_model.dart';

/// [CategoryEditorViewModel] を画面と同寿命で所有し、[CategoryEditorScreen] へ
/// 注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直され、新しいノートのRepositoryを持つViewModelに置き換わる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
///
/// ViewModelと同じく、追加・収入カテゴリの編集・支出カテゴリの編集を
/// 名前付きコンストラクタで作り分ける。
class CategoryEditorScreenHost extends StatefulWidget {
  /// カテゴリの追加。
  const CategoryEditorScreenHost.add({super.key})
    : _incomeCategory = null,
      _expenseCategory = null;

  /// 収入カテゴリ[category]の編集。
  const CategoryEditorScreenHost.editIncome({
    super.key,
    required IncomeCategory category,
  }) : _incomeCategory = category,
       _expenseCategory = null;

  /// 支出カテゴリ[category]の編集。
  const CategoryEditorScreenHost.editExpense({
    super.key,
    required ExpenseCategory category,
  }) : _incomeCategory = null,
       _expenseCategory = category;

  final IncomeCategory? _incomeCategory;
  final ExpenseCategory? _expenseCategory;

  @override
  State<CategoryEditorScreenHost> createState() =>
      _CategoryEditorScreenHostState();
}

class _CategoryEditorScreenHostState extends State<CategoryEditorScreenHost> {
  late final CategoryEditorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = _createViewModel();
  }

  CategoryEditorViewModel _createViewModel() {
    final incomeCategory = widget._incomeCategory;
    if (incomeCategory != null) {
      return CategoryEditorViewModel.editIncome(
        categoryRepository: context.read(),
        category: incomeCategory,
      );
    }
    final expenseCategory = widget._expenseCategory;
    if (expenseCategory != null) {
      return CategoryEditorViewModel.editExpense(
        categoryRepository: context.read(),
        category: expenseCategory,
      );
    }
    return CategoryEditorViewModel.add(categoryRepository: context.read());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CategoryEditorScreen(viewModel: _viewModel);
}
