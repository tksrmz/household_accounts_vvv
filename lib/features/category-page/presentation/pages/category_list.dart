import 'package:flutter/material.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/add_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/delete_category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_list.dart';
import 'package:household_accounts/util/presentation/widgets/delete_icon_button.dart';
import 'package:household_accounts/util/presentation/widgets/failure.dart';
import 'package:household_accounts/util/presentation/widgets/loading.dart';
import 'package:provider/provider.dart';

import 'add_category.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CategoryListState(
        context.read<RetrieveCategoriesUseCase>(),
        context.read<DeleteCategoryUseCase>(),
        context.read<AddCategoryUseCase>(),
      )..loadCategories(),
      child: _PageContents(),
    );
  }
}

class _PageContents extends StatelessWidget {
  const _PageContents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CategoryListState>();

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
        DeleteIconButton(
          onPressed: () {
            context.read<CategoryListState>().deleteCategory(_category.id);
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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => AddCategoryPage(
              state: context.read<CategoryListState>(),
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
    );
  }
}
