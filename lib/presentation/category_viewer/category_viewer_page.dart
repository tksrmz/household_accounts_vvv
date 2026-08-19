import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/logic/formatter.dart';
import '../../entity/category.dart';
import '../../feature/category_deletion/delete_expense_category_use_case.dart';
import '../../feature/category_deletion/delete_income_category_use_case.dart';
import '../../feature/category_editing/update_expense_category_use_case.dart';
import '../../feature/category_editing/update_income_category_use_case.dart';
import '../../feature/category_register/add_expense_category_use_case.dart';
import '../../feature/category_register/add_income_category_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/exception_or.dart';
import '../../v2/presentation/pages/state_managements/selected_note_state.dart';
import '../category_editor/category_editor_page.dart';
import '../common_widget/delete_icon_button.dart';
import '../common_widget/failure.dart';
import '../common_widget/loading.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';
import 'category_viewer_state.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<SelectedNoteState, IncomeCategoryListState>(
          create: (context) => IncomeCategoryListState(),
          update: (context, singleOrPair, state) {
            return state!..fetch(
              singleOrPair: singleOrPair.value,
              userInfo: context.read<UserInfo>(),
            );
          },
        ),
        ChangeNotifierProxyProvider<
          SelectedNoteState,
          ExpenseCategoryListState
        >(
          create: (context) => ExpenseCategoryListState(),
          update: (context, singleOrPair, state) {
            return state!..fetch(
              singleOrPair: singleOrPair.value,
              userInfo: context.read<UserInfo>(),
            );
          },
        ),
      ],
      child: _PageContent(),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListView(
            children: [
              _SectionTitle(text: '収入カテゴリ'),
              _IncomeCategoryList(),
              SizedBox(height: 40),
              _SectionTitle(text: '支出カテゴリ'),
              _ExpenseCategoryList(),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () async {
            final uinfo = context.read<UserInfo>();
            final sop = context.read<SelectedNoteState>().value;
            // ブランチNavigatorではなくルートNavigatorへpushし、編集画面がボトムナビを覆う従来挙動を維持する
            await Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => CategoryEditorPage(
                  title: 'カテゴリの追加',
                  onSubmit: (name, budget, type) async {
                    await _submit(name, budget, type, uinfo, sop);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            );
            if (!context.mounted) {
              return;
            }
            _reloadIncomeCategoryState(context);
            _reloadExpenseCategoryState(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline),
              const Text('カテゴリの追加'),
            ],
          ),
        ),
      ],
    );
  }

  Future<ExceptionOr<Unit>> _submit(
    String name,
    int budget,
    CategoryType type,
    UserInfo userInfo,
    SelectedNote sop,
  ) {
    switch (type) {
      case CategoryType.income:
        return sl<AddIncomeCategoryUseCase>()(
          AddIncomeCategoryInput(
            uid: userInfo.repoId(sop),
            name: name,
            repository: selectIncomeCategoryRepository(sop),
          ),
        );

      case CategoryType.expense:
        return sl<AddExpenseCategoryUseCase>()(
          AddExpenseCategoryInput(
            uid: userInfo.repoId(sop),
            name: name,
            repository: selectExpenseCategoryRepository(sop),
            budget: budget,
          ),
        );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.25),
      ),
    );
  }
}

class _IncomeCategoryList extends StatelessWidget {
  const _IncomeCategoryList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<IncomeCategoryListState>();

    if (state.hasFailure) {
      return FailureDisplayWidget(failure: state.failure!);
    }

    if (state.isLoading) {
      return LoadingWidget();
    }

    return state.categories.isEmpty
        ? const Text('収入カテゴリがありません。新規追加してください')
        : Column(
            children: state.categories
                .map((e) => _IncomeCategoryListItem(incomeCategory: e))
                .toList(growable: false),
          );
  }
}

class _IncomeCategoryListItem extends StatelessWidget {
  final IncomeCategory _incomeCategory;

  const _IncomeCategoryListItem({required IncomeCategory incomeCategory})
    : _incomeCategory = incomeCategory;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(_incomeCategory.name),
        Spacer(),
        _EditCategoryButton(originalData: _incomeCategory),
        DeleteIconButton(onPressed: () => _deleteIncomeCategory(context)),
      ],
    );
  }

  Future<void> _deleteIncomeCategory(BuildContext context) async {
    final input = _generateInput(context);
    final delete = sl<DeleteIncomeCategoryUseCase>();
    final result = await delete(input);
    result.fold(
      (exception) =>
          _showExceptionDialog(context, '収入カテゴリの削除に失敗しました', exception),
      (_) => _reloadIncomeCategoryState(context),
    );
  }

  DeleteIncomeCategoryInput _generateInput(BuildContext context) {
    final sop = context.read<SelectedNoteState>().value;
    return DeleteIncomeCategoryInput(
      repository: selectIncomeCategoryRepository(sop),
      uid: context.read<UserInfo>().repoId(sop),
      categoryId: _incomeCategory.id,
    );
  }
}

class _ExpenseCategoryList extends StatelessWidget {
  const _ExpenseCategoryList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseCategoryListState>();

    if (state.hasFailure) {
      return FailureDisplayWidget(failure: state.failure!);
    }

    if (state.isLoading) {
      return LoadingWidget();
    }

    return state.categories.isEmpty
        ? const Text('支出カテゴリがありません。新規追加してください')
        : Column(
            children: state.categories
                .map((e) => _ExpenseCategoryListItem(expenseCategory: e))
                .toList(growable: false),
          );
  }
}

class _ExpenseCategoryListItem extends StatelessWidget {
  final ExpenseCategory _expenseCategory;

  const _ExpenseCategoryListItem({required ExpenseCategory expenseCategory})
    : _expenseCategory = expenseCategory;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          '${_expenseCategory.name} (予算: ${Formatter.simpleCurrency(_expenseCategory.totalBudget)})',
        ),
        Spacer(),
        _EditCategoryButton(originalData: _expenseCategory),
        DeleteIconButton(onPressed: () => _deleteExpenseCategory(context)),
      ],
    );
  }

  Future<void> _deleteExpenseCategory(BuildContext context) async {
    final input = _generateInput(context);
    final delete = sl<DeleteExpenseCategoryUseCase>();
    final result = await delete(input);
    result.fold(
      (exception) =>
          _showExceptionDialog(context, '支出カテゴリの削除に失敗しました', exception),
      (_) => _reloadExpenseCategoryState(context),
    );
  }

  DeleteExpenseCategoryInput _generateInput(BuildContext context) {
    final sop = context.read<SelectedNoteState>().value;
    return DeleteExpenseCategoryInput(
      repository: selectExpenseCategoryRepository(sop),
      uid: context.read<UserInfo>().repoId(sop),
      categoryId: _expenseCategory.id,
    );
  }
}

class _EditCategoryButton extends StatelessWidget {
  const _EditCategoryButton({required CategoryBase originalData})
    : _originalData = originalData;

  final CategoryBase _originalData;

  @override
  Widget build(BuildContext context) {
    final int? budget;
    switch (_originalData.type) {
      case CategoryType.income:
        budget = null;
        break;
      case CategoryType.expense:
        budget = (_originalData as ExpenseCategory).totalBudget;
        break;
    }
    return IconButton(
      onPressed: () async {
        final sop = context.read<SelectedNoteState>().value;
        final uinfo = context.read<UserInfo>();

        // ブランチNavigatorではなくルートNavigatorへpushし、編集画面がボトムナビを覆う従来挙動を維持する
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => CategoryEditorPage(
              title: '編集',
              initialName: _originalData.name,
              initialBudget: budget,
              initialType: _originalData.type,
              canChangeType: false,
              onSubmit: (name, budget, type) async {
                await _update(name, budget, type, uinfo, sop);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        );
        if (!context.mounted) {
          return;
        }
        _reloadIncomeCategoryState(context);
        _reloadExpenseCategoryState(context);
      },
      icon: const Icon(Icons.edit),
    );
  }

  Future<ExceptionOr<Unit>> _update(
    String name,
    int budget,
    CategoryType type,
    UserInfo uinfo,
    SelectedNote sop,
  ) {
    switch (type) {
      case CategoryType.income:
        return sl<UpdateIncomeCategoryUseCase>()(
          UpdateIncomeCategoryInput(
            uid: uinfo.repoId(sop),
            categoryId: _originalData.id,
            repository: selectIncomeCategoryRepository(sop),
            name: name,
          ),
        );

      case CategoryType.expense:
        return sl<UpdateExpenseCategoryUseCase>()(
          UpdateExpenseCategoryInput(
            uid: uinfo.repoId(sop),
            categoryId: _originalData.id,
            repository: selectExpenseCategoryRepository(sop),
            name: name,
            budget: budget,
          ),
        );
    }
  }
}

Future<void> _reloadIncomeCategoryState(BuildContext context) =>
    context.read<IncomeCategoryListState>().fetch(
      singleOrPair: context.read<SelectedNoteState>().value,
      userInfo: context.read<UserInfo>(),
    );

Future<void> _reloadExpenseCategoryState(BuildContext context) =>
    context.read<ExpenseCategoryListState>().fetch(
      singleOrPair: context.read<SelectedNoteState>().value,
      userInfo: context.read<UserInfo>(),
    );

Future<void> _showExceptionDialog(
  BuildContext context,
  String title,
  Exception exception,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: Text('$exception'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ],
  ),
);
