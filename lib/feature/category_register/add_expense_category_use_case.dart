import 'package:dartz/dartz.dart';

import '../../entity/category_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef AddExpenseCategoryUseCase = UseCase<AddExpenseCategoryInput, Unit>;

class AddExpenseCategoryInput {
  /// User ID.
  final String uid;

  /// Name of new category.
  final String name;

  /// Budget of new cateogry.
  final int budget;

  final Repository<ExpenseCategory> repository;

  const AddExpenseCategoryInput({
    required this.uid,
    required this.name,
    required this.budget,
    required this.repository,
  });
}
