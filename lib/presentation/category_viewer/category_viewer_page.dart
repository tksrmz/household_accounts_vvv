import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/presentation/category_viewer/category_viewer_state.dart';
import 'package:household_accounts/presentation/common_widget/delete_icon_button.dart';
import 'package:household_accounts/util/type/exception_or.dart';
import 'package:provider/provider.dart';

import '../../feature/category_deletion/delete_expense_category_use_case.dart';
import '../../feature/category_deletion/delete_income_category_use_case.dart';
import '../../feature/category_editing/update_expense_category_use_case.dart';
import '../../feature/category_editing/update_income_category_use_case.dart';
import '../../feature/category_register/add_expense_category_use_case.dart';
import '../../feature/category_register/add_income_category_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../category_editor/category_editor_page.dart';
import '../common_widget/failure.dart';
import '../common_widget/loading.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';

class CategoryListPage2 extends StatelessWidget {
  const CategoryListPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<SingleOrPair, IncomeCategoryListState>(
          create: (context) => IncomeCategoryListState(),
          update: (context, singleOrPair, state) {
            return state!
              ..fetch(
                singleOrPair: singleOrPair,
                userInfo: context.read<UserInfo>(),
              );
          },
        ),
        ChangeNotifierProxyProvider<SingleOrPair, ExpenseCategoryListState>(
          create: (context) => ExpenseCategoryListState(),
          update: (context, singleOrPair, state) {
            return state!
              ..fetch(
                singleOrPair: singleOrPair,
                userInfo: context.read<UserInfo>(),
              );
          },
        ),
      ],
      child: _PageContent2(),
    );
  }
}

class _PageContent2 extends StatelessWidget {
  const _PageContent2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListView(
            children: [
              _SectionTitle(text: 'INCOME CATEGORIES'),
              _IncomeCategoryList(),
              SizedBox(height: 40),
              _SectionTitle(text: 'EXPENSE CATEGORIES'),
              _ExpenseCategoryList(),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () async {
            final uinfo = context.read<UserInfo>();
            final sop = context.read<SingleOrPair>();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryEditorPage(
                  title: 'Add a new category',
                  onSubmit: (name, budget, type) async {
                    await _submit(name, budget, type, uinfo, sop);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
            _reloadIncomeCategoryState(context);
            _reloadExpenseCategoryState(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline),
              const Text('Add a new category.'),
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
    SingleOrPair sop,
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
  const _SectionTitle({Key? key, required this.text}) : super(key: key);

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
  const _IncomeCategoryList({Key? key}) : super(key: key);

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
        ? const Text('No income categories exist. Add new one.')
        : Column(
      children: state.categories
          .map(
            (e) => _IncomeCategoryListItem(
          incomeCategory: e,
        ),
      )
          .toList(growable: false),
    );
  }
}

class _IncomeCategoryListItem extends StatelessWidget {
  final IncomeCategory _incomeCategory;

  const _IncomeCategoryListItem({
    Key? key,
    required IncomeCategory incomeCategory,
  })  : _incomeCategory = incomeCategory,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(_incomeCategory.name),
        Spacer(),
        _EditCategoryButton2(originalData: _incomeCategory),
        DeleteIconButton(
          onPressed: () => _deleteIncomeCategory(context),
        ),
      ],
    );
  }

  Future<void> _deleteIncomeCategory(BuildContext context) async {
    final input = _generateInput(context);
    final delete = sl<DeleteIncomeCategoryUseCase>();
    final result = await delete(input);
    result.fold(
          (exception) => _showExceptionDialog(
        context,
        'Deleting Income Category Failed',
        exception,
      ),
          (_) => _reloadIncomeCategoryState(context),
    );
  }

  DeleteIncomeCategoryInput _generateInput(BuildContext context) {
    final sop = context.read<SingleOrPair>();
    return DeleteIncomeCategoryInput(
      repository: selectIncomeCategoryRepository(sop),
      uid: context.read<UserInfo>().repoId(sop),
      categoryId: _incomeCategory.id,
    );
  }
}

class _ExpenseCategoryList extends StatelessWidget {
  const _ExpenseCategoryList({Key? key}) : super(key: key);

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
        ? const Text('No expense categories exist. Add new one.')
        : Column(
      children: state.categories
          .map(
            (e) => _ExpenseCategoryListItem(
          expenseCategory: e,
        ),
      )
          .toList(growable: false),
    );
  }
}

class _ExpenseCategoryListItem extends StatelessWidget {
  final ExpenseCategory _expenseCategory;

  const _ExpenseCategoryListItem({
    Key? key,
    required ExpenseCategory expenseCategory,
  })  : _expenseCategory = expenseCategory,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          '${_expenseCategory.name} (Budget: ${_expenseCategory.totalBudget})',
        ),
        Spacer(),
        _EditCategoryButton2(originalData: _expenseCategory),
        DeleteIconButton(
          onPressed: () => _deleteExpenseCategory(context),
        ),
      ],
    );
  }

  Future<void> _deleteExpenseCategory(BuildContext context) async {
    final input = _generateInput(context);
    final delete = sl<DeleteExpenseCategoryUseCase>();
    final result = await delete(input);
    result.fold(
          (exception) => _showExceptionDialog(
        context,
        'Deleting Expense Category Failed',
        exception,
      ),
          (_) => _reloadExpenseCategoryState(context),
    );
  }

  DeleteExpenseCategoryInput _generateInput(BuildContext context) {
    final sop = context.read<SingleOrPair>();
    return DeleteExpenseCategoryInput(
      repository: selectExpenseCategoryRepository(sop),
      uid: context.read<UserInfo>().repoId(sop),
      categoryId: _expenseCategory.id,
    );
  }
}

class _EditCategoryButton2 extends StatelessWidget {
  const _EditCategoryButton2({
    Key? key,
    required Category2 originalData,
  })  : _originalData = originalData,
        super(key: key);

  final Category2 _originalData;

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
        final sop = context.read<SingleOrPair>();
        final uinfo = context.read<UserInfo>();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryEditorPage(
              title: 'Edit',
              initialName: _originalData.name,
              initialBudget: budget,
              initialType: _originalData.type,
              canChangeType: false,
              onSubmit: (name, budget, type) async {
                await _update(name, budget, type, uinfo, sop);
                Navigator.pop(context);
              },
            ),
          ),
        );
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
    SingleOrPair sop,
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
      singleOrPair: context.read<SingleOrPair>(),
      userInfo: context.read<UserInfo>(),
    );

Future<void> _reloadExpenseCategoryState(BuildContext context) =>
    context.read<ExpenseCategoryListState>().fetch(
      singleOrPair: context.read<SingleOrPair>(),
      userInfo: context.read<UserInfo>(),
    );

Future<void> _showExceptionDialog(BuildContext context,
    String title,
    Exception exception,
) =>
    showDialog<void>(
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
