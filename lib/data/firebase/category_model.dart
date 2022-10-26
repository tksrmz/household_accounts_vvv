import 'package:household_accounts/entity/category_entity.dart';

import '../../util/type/json.dart';

class IncomeCategoryModel extends IncomeCategory {
  IncomeCategoryModel.fromIncomeCategory(IncomeCategory category)
      : super(
          id: category.id,
          name: category.name,
        );

  IncomeCategoryModel.fromJson(Json json)
      : super(
          id: json['id'] as String,
          name: json['name'] as String,
        );

  Json toJson() => {
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

  ExpenseCategoryModel.fromJson(Json json)
      : super(
          id: json['id'] as String,
          name: json['name'] as String,
          totalBudget: json['totalBudget'] as int,
        );

  Json toJson() => {
        'name': name,
        'type': type.toShortString(),
        'totalBudget': totalBudget,
      };
}
