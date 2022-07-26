import 'package:flutter/material.dart';
import 'package:household_accounts/service_locator.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/util/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/update_category.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_page.dart';
import 'package:household_accounts/util/failure_or.dart';
import 'package:household_accounts/util/presentation/widgets/delete_icon_button.dart';
import 'package:household_accounts/util/presentation/widgets/failure.dart';
import 'package:household_accounts/util/presentation/widgets/loading.dart';
import 'package:household_accounts/util/use_case.dart';
import 'package:provider/provider.dart';

import 'add_category.dart';
import 'edit_category.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CategoryPageState(
        sl<RetrieveCategoriesUseCase>(),
        sl<DeleteCategoryUseCase>(),
        sl<AddCategoryUseCase>(),
        sl<UpdateCategoryUseCase>(),
      )..loadCategories(),
      child: _PageContents(),
    );
  }
}

class _PageContents extends StatelessWidget {
  const _PageContents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoryPageState>();

    if (state.hasFailure) {
      return Center(
        child: FailureDisplayWidget(failure: state.failure!),
      );
    }

    if (state.isLoading) {
      return Center(
        child: LoadingWidget(),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _CategoryListView(
            incomeCategories: state.incomeCategories,
            expenseCategories: state.expenseCategories,
          ),
        ),
        _AddCategoryButton(),
      ],
    );
  }
}

class _CategoryListView extends StatelessWidget {
  final List<Category> _incomeCategories;
  final List<Category> _expenseCategories;

  const _CategoryListView({
    required List<Category> incomeCategories,
    required List<Category> expenseCategories,
    Key? key,
  })  : _incomeCategories = incomeCategories,
        _expenseCategories = expenseCategories,
        super(key: key);

  List<Widget> _toListViewChildren(
    String headline,
    String emptyCategoryString,
    List<Category> categories,
  ) {
    final children = <Widget>[];

    children.add(Text(
      headline,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));

    if (categories.isEmpty) {
      children.add(Text(emptyCategoryString));
    } else {
      categories.forEach((element) {
        children.add(_CategoryListItem(category: element));
      });
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    children.addAll(_toListViewChildren(
      'Income Categories',
      'No income categories registered.',
      _incomeCategories,
    ));
    children.addAll(_toListViewChildren(
      'Expense Categories',
      'No expense categories registered.',
      _expenseCategories,
    ));

    return ListView(children: children);
  }
}

class _CategoryListItem extends StatelessWidget {
  final Category _category;

  const _CategoryListItem({required Category category, Key? key})
      : _category = category,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(_category.name),
        _EditCategoryButton(categoryId: _category.id),
        DeleteIconButton(
          onPressed: () {
            context.read<CategoryPageState>().deleteCategory(_category.id);
          },
        ),
      ],
    );
  }
}

class _AddCategoryButton extends StatelessWidget {
  const _AddCategoryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // onPressed: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (newContext) => AddCategoryPage(
      //           // state: context.read<CategoryPageState>(),
      //           ),
      //     ),
      //   );
      // },
      onPressed: null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline),
          const Text('Add a new category.'),
        ],
      ),
    );
  }
}

class _EditCategoryButton extends StatelessWidget {
  final String _categoryId;

  const _EditCategoryButton({required String categoryId, Key? key})
      : _categoryId = categoryId,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => EditCategoryPage(
              state: context.read<CategoryPageState>(),
              categoryId: _categoryId,
            ),
          ),
        );
      },
      icon: const Icon(Icons.edit),
    );
  }
}

class CategoryListPage2 extends StatelessWidget {
  const CategoryListPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => IncomeCategoryListState(
            sl<RetrieveIncomeCategoriesUseCase>(),
            sl<DeleteIncomeCategoryUseCase>(),
            sl<AddCategoryUseCase2>(),
            sl<UpdateIncomeCategoryUseCase>(),
          )..loadState(),
        ),
        ChangeNotifierProvider(
          create: (context) => ExpenseCategoryListState(
            sl<RetrieveExpenseCategoriesUseCase>(),
            sl<DeleteExpenseCategoryUseCase>(),
            sl<AddCategoryUseCase2>(),
            sl<UpdateExpenseCategoryUseCase>(),
          )..loadState(),
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
            const Text('INCOME CATEGORIES'),
            _IncomeCategoryList(),
            const Text('EXPENSE CATEGORIES'),
            _ExpenseCategoryList(),
          ],
        )),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (newContext) => AddCategoryPage2(
                  onSubmit: (name, budget, categoryType) {
                    switch (categoryType) {
                      case CategoryType.income:
                        context
                            .read<IncomeCategoryListState>()
                            .addCategory(name);
                        break;
                      case CategoryType.expense:
                        context
                            .read<ExpenseCategoryListState>()
                            .addCategory(name, budget);
                        break;
                    }
                    Navigator.pop(newContext);
                  },
                ),
              ),
            );
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

class _IncomeCategoryList extends StatelessWidget {
  const _IncomeCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<IncomeCategoryListState>();

    if (state.hasFailure) {
      return Text(state.failure!.toString());
    }

    if (state.isLoading) {
      return Column(
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Awaiting result...'),
          )
        ],
      );
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
        _EditCategoryButton2(originalData: _incomeCategory),
        DeleteIconButton(
          onPressed: () {
            context.read<IncomeCategoryListState>().deleteCategory(
                  _incomeCategory.id,
                );
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
      return Text(state.failure!.toString());
    }

    if (state.isLoading) {
      return Column(
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Awaiting result...'),
          )
        ],
      );
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
        _EditCategoryButton2(originalData: _expenseCategory),
        DeleteIconButton(
          onPressed: () {
            context
                .read<ExpenseCategoryListState>()
                .deleteCategory(_expenseCategory.id);
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => EditCategoryPage2(
              originalData: _originalData,
              onSubmit: (name, budget, categoryType) {
                switch (categoryType) {
                  case CategoryType.income:
                    context.read<IncomeCategoryListState>().updateCategory(
                          _originalData as IncomeCategory,
                          name,
                        );
                    break;
                  case CategoryType.expense:
                    context.read<ExpenseCategoryListState>().updateCategory(
                          _originalData as ExpenseCategory,
                          name,
                          budget,
                        );
                    break;
                }
                Navigator.pop(newContext);
              },
            ),
          ),
        );
      },
      icon: const Icon(Icons.edit),
    );
  }
}
