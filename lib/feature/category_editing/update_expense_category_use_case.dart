import 'package:dartz/dartz.dart';

import '../../entity/category.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef UpdateExpenseCategoryUseCase
    = UseCase<UpdateExpenseCategoryInput, Unit>;

class UpdateExpenseCategoryInput {
  /// User ID or Pair ID.
  final String uid;

  /// ID of the expense category to be updated.
  final String categoryId;

  /// New category name.
  ///
  /// If this value is null, the category name will not change.
  final String? name;

  /// New budget
  ///
  /// If this value is null, the category budget will not change.
  final int? budget;

  final Repository<ExpenseCategory> repository;

  UpdateExpenseCategoryInput({
    required this.uid,
    required this.categoryId,
    this.name,
    this.budget,
    required this.repository,
  });
}
