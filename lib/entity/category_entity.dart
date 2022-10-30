import 'package:household_accounts/util/type/identifiable.dart';

import 'budget_entity.dart';

enum CategoryType { income, expense }

/// Base class for income and expense categories.
abstract class Category2 extends Identifiable {
  /// Maximum characters in the name of a category.
  static const int maxNameLength = 20;

  /// Name of this category.
  /// [name.length] must be less than or equal to [maxNameLength].
  final String name;

  // Do I still need this property???
  final CategoryType type;

  const Category2({
    required String id,
    required this.name,
    required this.type,
  })  : assert(name.length <= maxNameLength, 'Too long name.'),
        super(id);

  @override
  List<Object> get props => [
        ...super.props,
        name,
        type,
      ];
}

/// Category for income records.
///
/// No additional properties or methods are needed on this class
/// as [Category2] has all of them that this class requires.
class IncomeCategory extends Category2 {
  const IncomeCategory({
    required String id,
    required String name,
  }) : super(
          id: id,
          name: name,
          type: CategoryType.income,
        );

  IncomeCategory copyWith({
    String? id,
    String? name,
  }) =>
      IncomeCategory(
        id: id ?? this.id,
        name: name ?? this.name,
      );
}

const deletedIncomeCategory =
    const IncomeCategory(id: 'deleted-income-category', name: '削除済み');

/// Category for expense records.
///
/// A difference between this class and [IncomeCategory] is that
/// this uses [Budget] class but the other is not.
class ExpenseCategory extends Category2 {
  final Budget _budget;

  int get totalBudget => _budget.amount;

  ExpenseCategory({
    required String id,
    required String name,
    required int totalBudget,
  })  : _budget = Budget(totalBudget),
        super(
          id: id,
          name: name,
          type: CategoryType.expense,
        );

  ExpenseCategory copyWith({
    String? id,
    String? name,
    int? totalBudget,
  }) =>
      ExpenseCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        totalBudget: totalBudget ?? this.totalBudget,
      );

  @override
  List<Object> get props => [
        ...super.props,
        ..._budget.props,
      ];
}

final deletedExpenseCategory = ExpenseCategory(
  id: 'deleted-expense-category',
  name: '削除済み',
  totalBudget: 0,
);