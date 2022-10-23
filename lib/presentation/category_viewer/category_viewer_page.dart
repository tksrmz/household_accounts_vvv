import 'package:flutter/material.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/presentation/category_viewer/category_viewer_state.dart';
import 'package:household_accounts/presentation/common_widget/delete_icon_button.dart';
import 'package:provider/provider.dart';

import '../../feature/category_deletion/delete_income_category_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../category_editor/add_category_page.dart';
import '../common_widget/failure.dart';
import '../common_widget/loading.dart';
import '../util/model/user_info.dart';

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
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (newContext) => AddCategoryPage2(
                  singleOrPair: context.read<SingleOrPair>(),
                  userInfo: context.read<UserInfo>(),
                ),
              ),
            );
            await _reloadIncomeCategoryState(context);
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
          onPressed: () {
            // context.read<IncomeCategoryListState>().deleteCategory(
            //       _incomeCategory.id,
            //     );
          },
        ),
      ],
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
          onPressed: () {
            // context
            //     .read<ExpenseCategoryListState>()
            //     .deleteCategory(_expenseCategory.id);
          },
        ),
      ],
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
    return IconButton(
      onPressed: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (newContext) => EditCategoryPage2(
        //       originalData: _originalData,
        //       onSubmit: (name, budget, categoryType) {
        //         switch (categoryType) {
        //           case CategoryType.income:
        //             context.read<IncomeCategoryListState>().updateCategory(
        //                   _originalData as IncomeCategory,
        //                   name,
        //                 );
        //             break;
        //           case CategoryType.expense:
        //             context.read<ExpenseCategoryListState>().updateCategory(
        //                   _originalData as ExpenseCategory,
        //                   name,
        //                   budget,
        //                 );
        //             break;
        //         }
        //         Navigator.pop(newContext);
        //       },
        //     ),
        //   ),
        // );
      },
      icon: const Icon(Icons.edit),
    );
  }
}

Future<void> _reloadIncomeCategoryState(BuildContext context) =>
    context.read<IncomeCategoryListState>().fetch(
          singleOrPair: context.read<SingleOrPair>(),
          userInfo: context.read<UserInfo>(),
        );
