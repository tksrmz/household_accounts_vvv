import 'package:household_accounts/util/domain/entities/category.dart';

@deprecated
class CategoryModel extends Category {
  CategoryModel.fromCategory(Category category)
      : super(
    category.id,
    category.name,
    category.type,
    // category.budget,
  );

  CategoryModel.fromIdAndJson(String id, Map<String, Object?> json)
      : super(
    id,
    json['name'] as String,
          RecordTypeParsing.fromShortString(json['type'] as String),
          // 0, // Budget is not used (currently).
        );

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type.toShortString(),
      };
}

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
