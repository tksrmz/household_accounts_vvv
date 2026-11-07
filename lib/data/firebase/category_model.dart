import 'package:household_accounts/entity/category.dart';

import '../../util/type/json.dart';
import 'data_model.dart';

class IncomeCategoryModel implements DataModel<IncomeCategory> {
  IncomeCategoryModel.fromJson(Json json)
    : id = json['id'] as String,
      name = json['name'] as String;

  final String id;
  final String name;

  @override
  IncomeCategory toEntity() => IncomeCategory(id: id, name: name);

  @override
  Json toJson() => {'name': name, 'type': 'income'};
}

class ExpenseCategoryModel implements DataModel<ExpenseCategory> {
  ExpenseCategoryModel.fromExpenseCategory(ExpenseCategory category)
    : id = category.id,
      name = category.name,
      totalBudget = category.totalBudget;

  ExpenseCategoryModel.fromJson(Json json)
    : id = json['id'] as String,
      name = json['name'] as String,
      totalBudget = json['totalBudget'] as int;

  final String id;
  final String name;
  final int totalBudget;

  @override
  ExpenseCategory toEntity() =>
      ExpenseCategory(id: id, name: name, totalBudget: totalBudget);

  @override
  Json toJson() => {
    'name': name,
    'type': 'expense',
    'totalBudget': totalBudget,
  };
}
