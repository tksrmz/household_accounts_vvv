import 'package:dartz/dartz.dart';

import '../../entity/category_entity.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef DeleteExpenseCategoryUseCase
    = UseCase2<DeleteExpenseCategoryInput, Unit>;

class DeleteExpenseCategoryInput {
  /// User ID or pair ID.
  final String uid;

  /// ID of the category to be deleted.
  final String categoryId;

  /// Repository from which delete the category.
  final Repository2<ExpenseCategory> repository;

  const DeleteExpenseCategoryInput({
    required this.uid,
    required this.categoryId,
    required this.repository,
  });
}
