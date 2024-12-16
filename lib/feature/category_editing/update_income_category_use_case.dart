import 'package:dartz/dartz.dart';

import '../../entity/category.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef UpdateIncomeCategoryUseCase = UseCase<UpdateIncomeCategoryInput, Unit>;

class UpdateIncomeCategoryInput {
  /// User ID or Pair ID.
  final String uid;

  /// ID of the income category to be updated.
  final String categoryId;

  /// New category name.
  ///
  /// If this value is null, the category name will not change.
  final String? name;

  final Repository<IncomeCategory> repository;

  UpdateIncomeCategoryInput({
    required this.uid,
    required this.categoryId,
    this.name,
    required this.repository,
  });
}
