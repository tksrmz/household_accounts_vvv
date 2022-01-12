import 'package:flutter/widgets.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/use-cases/retrieve_categories.dart';
import 'package:household_accounts/features/category-page/presentation/states/category_list.dart';
import 'package:household_accounts/util/presentation/widgets/failure.dart';
import 'package:household_accounts/util/presentation/widgets/loading.dart';
import 'package:provider/provider.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          CategoryListState(context.read<RetrieveCategoriesUseCase>())
            ..loadCategories(),
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

    return _CategoryListView(
      incomeCategories: state.incomeCategories,
      expenseCategories: state.expenseCategories,
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

  @override
  Widget build(BuildContext context) {
    const boldStyle = const TextStyle(fontWeight: FontWeight.bold);

    final children = <Widget>[
      const Text(
        'Income Categories',
        style: boldStyle,
      ),
    ];

    if (_incomeCategories.isEmpty) {
      children.add(const Text(
        'No income categories registered.',
      ));
    } else {
      _incomeCategories.forEach((element) => children.add(Text(element.name)));
    }

    children.add(const Text(
      'Expense Categories',
      style: boldStyle,
    ));

    if (_expenseCategories.isEmpty) {
      children.add(const Text('No expense categories registered.'));
    } else {
      _expenseCategories.forEach((element) => children.add(Text(element.name)));
    }

    return ListView(children: children);
  }
}
