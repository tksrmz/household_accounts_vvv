import 'package:household_accounts/util/domain/entities/identifiable.dart';

class Category extends Identifiable {
  static const int maxNameLength = 20;

  final String name;
  final CategoryType type;
  // final int budget;

  // Isn't it strange to define "budgets" to income categories?
  Category(String id, this.name, this.type /*, this.budget*/)
      : assert(name.length > 0, 'Category name is empty string.'),
        assert(name.length <= Category.maxNameLength,
            'Category name is too long.'),
        // assert(budget >= 0, 'Budget is negative.'),
        super(id);

  @override
  List<Object> get props => [
        id,
        name,
        type /*, budget*/
      ];
}

enum CategoryType { income, expense }

extension RecordTypeParsing on CategoryType {
  String toShortString() => this.toString().split('.').last;

  static CategoryType fromShortString(String str) {
    if (str == CategoryType.expense.toShortString())
      return CategoryType.expense;
    if (str == CategoryType.income.toShortString()) return CategoryType.income;

    throw 'Invalid short string of RecordType';
  }
}
