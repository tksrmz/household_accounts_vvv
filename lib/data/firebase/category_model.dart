import 'package:household_accounts/entity/category_entity.dart';

class IncomeCategoryModel extends IncomeCategory {
  IncomeCategoryModel.fromIncomeCategory(IncomeCategory category)
      : super(
          id: category.id,
          name: category.name,
        );

  IncomeCategoryModel.fromIdAndJson(String id, Map<String, Object?> json)
      : super(
          id: id,
          name: json['name'] as String,
        );

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type.toShortString(),
      };
}

class ExpenseCategoryModel extends ExpenseCategory {
  ExpenseCategoryModel.fromExpenseCategory(ExpenseCategory category)
      : super(
          id: category.id,
          name: category.name,
          totalBudget: category.totalBudget,
        );

  ExpenseCategoryModel.fromIdAndJson(String id, Map<String, Object?> json)
      : super(
          id: id,
          name: json['name'] as String,
          totalBudget: json['totalBudget'] as int,
        );

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type.toShortString(),
        'totalBudget': totalBudget,
      };
}
