import '../util/type/identifiable.dart';
import '../vo/budget_amount.dart';

enum CategoryType { income, expense }

/// Base class for income and expense categories.
abstract class CategoryBase extends Identifiable {
  /// Maximum characters in the name of a category.
  static const int maxNameLength = 20;

  /// Name of this category.
  /// [name.length] must be less than or equal to [maxNameLength].
  final String name;

  // Do I still need this property???
  final CategoryType type;

  const CategoryBase({
    required String id,
    required this.name,
    required this.type,
  }) : assert(name.length <= maxNameLength, 'Too long name.'),
       super(id);

  @override
  List<Object> get props => [...super.props, name, type];
}

/// Category for income records.
///
/// No additional properties or methods are needed on this class
/// as [CategoryBase] has all of them that this class requires.
class IncomeCategory extends CategoryBase {
  const IncomeCategory({required super.id, required super.name})
    : super(type: CategoryType.income);

  IncomeCategory copyWith({String? id, String? name}) =>
      IncomeCategory(id: id ?? this.id, name: name ?? this.name);
}

const deletedIncomeCategory = IncomeCategory(
  id: 'deleted-income-category',
  name: '削除済み',
);

/// Category for expense records.
///
/// A difference between this class and [IncomeCategory] is that
/// this uses [BudgetAmount] class but the other is not.
class ExpenseCategory extends CategoryBase {
  final BudgetAmount _budget;

  int get totalBudget => _budget.value;

  ExpenseCategory({
    required super.id,
    required super.name,
    required int totalBudget,
  }) : _budget = BudgetAmount(totalBudget),
       super(type: CategoryType.expense);

  ExpenseCategory copyWith({String? id, String? name, int? totalBudget}) =>
      ExpenseCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        totalBudget: totalBudget ?? this.totalBudget,
      );

  @override
  List<Object> get props => [...super.props, _budget.value];
}

final deletedExpenseCategory = ExpenseCategory(
  id: 'deleted-expense-category',
  name: '削除済み',
  totalBudget: 0,
);
