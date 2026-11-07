import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/logic/formatter.dart';
import '../../domain/models/category_id.dart';
import '../../routing/routes.dart';
import '../../utils/command.dart';
import '../core/widgets/delete_confirmation_dialog.dart';
import 'categories_view_model.dart';
import 'widgets/category_row.dart';
import 'widgets/category_section.dart';

/// カテゴリ一覧画面。
///
/// 旧画面どおり、1つのリストに収入カテゴリと支出カテゴリの2セクションを
/// 縦に並べる。シェル(タブ)の本体として表示されるため、Scaffoldは持たない。
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required CategoriesViewModel viewModel})
    : _viewModel = viewModel;

  final CategoriesViewModel _viewModel;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    widget._viewModel.deleteIncome.addListener(_onDeleteIncomeResult);
    widget._viewModel.deleteExpense.addListener(_onDeleteExpenseResult);
  }

  @override
  void dispose() {
    widget._viewModel.deleteIncome.removeListener(_onDeleteIncomeResult);
    widget._viewModel.deleteExpense.removeListener(_onDeleteExpenseResult);
    super.dispose();
  }

  void _onDeleteIncomeResult() =>
      _showDeleteFailure(widget._viewModel.deleteIncome, '収入カテゴリの削除に失敗しました');

  void _onDeleteExpenseResult() =>
      _showDeleteFailure(widget._viewModel.deleteExpense, '支出カテゴリの削除に失敗しました');

  /// 削除の失敗をスナックバーで伝える。
  ///
  /// 成功を知らせないのは、削除された行が一覧から消えること自体が結果の表示に
  /// なっているためである。build内ではなくコマンドのリスナーで表示するのは、
  /// スナックバーが「状態」ではなく「一度きりの出来事」だからである(buildは
  /// 再ビルドのたびに走るため、副作用の発火回数を画面の描画回数から切り離す)。
  void _showDeleteFailure(Command<void> command, String message) {
    if (!command.error) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    // 表示済みのエラーを消し、次の失敗でも再びスナックバーが出るようにする
    command.clearResult();
  }

  /// 削除してよいかを確かめてから、[delete]で削除する。
  ///
  /// 確認をViewModelの状態にしないのは、確認ダイアログが「この操作を本当に
  /// 実行するか」を利用者に問うUIの手続きであり、データの状態ではないため
  /// (ViewModelは確認済みの削除だけを受け取る)。
  Future<void> _confirmAndDelete(
    Command1<void, CategoryId> delete, {
    required CategoryId id,
    required String name,
  }) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      targetName: name,
    );
    // ダイアログを開いている間にノート切替で画面が作り直されていたら、
    // 古いノートのカテゴリを消さない
    if (!confirmed || !mounted) {
      return;
    }
    await delete.execute(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget._viewModel;

    return ListenableBuilder(
      // 削除コマンドの実行状態(実行中の無効化)も描画に反映するため、
      // VMと2つのコマンドを監視する
      listenable: Listenable.merge([
        viewModel,
        viewModel.deleteIncome,
        viewModel.deleteExpense,
      ]),
      builder: (context, _) {
        // 削除コマンドは実行中の再実行を黙って捨てるため、実行中は同じ種別の
        // 削除アイコンを無効化し、押しても何も起きないタップが生まれないようにする
        final incomeDeleteEnabled = !viewModel.deleteIncome.running;
        final expenseDeleteEnabled = !viewModel.deleteExpense.running;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  CategorySection(
                    title: '収入カテゴリ',
                    isLoading: viewModel.isIncomeLoading,
                    hasError: viewModel.incomeLoadError != null,
                    emptyMessage: '収入カテゴリがありません。新規追加してください',
                    rows: viewModel.incomeCategories
                        .map<Widget>(
                          (category) => CategoryRow(
                            label: category.name.value,
                            onEditPressed: () => context.push(
                              Routes.categoryEdit,
                              extra: category,
                            ),
                            onDeletePressed: incomeDeleteEnabled
                                ? () => _confirmAndDelete(
                                    viewModel.deleteIncome,
                                    id: category.id,
                                    name: category.name.value,
                                  )
                                : null,
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 40),
                  CategorySection(
                    title: '支出カテゴリ',
                    isLoading: viewModel.isExpenseLoading,
                    hasError: viewModel.expenseLoadError != null,
                    emptyMessage: '支出カテゴリがありません。新規追加してください',
                    rows: viewModel.expenseCategories
                        .map<Widget>(
                          (category) => CategoryRow(
                            label:
                                '${category.name.value} (予算: '
                                '${Formatter.simpleCurrency(category.budget.value)})',
                            onEditPressed: () => context.push(
                              Routes.categoryEdit,
                              extra: category,
                            ),
                            onDeletePressed: expenseDeleteEnabled
                                ? () => _confirmAndDelete(
                                    viewModel.deleteExpense,
                                    id: category.id,
                                    name: category.name.value,
                                  )
                                : null,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => context.push(Routes.categoryNew),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.add_circle_outline), Text('カテゴリの追加')],
              ),
            ),
          ],
        );
      },
    );
  }
}
