import 'package:dartz/dartz.dart';

import '../../entity/category.dart';
import '../../util/type/repository.dart';
import '../../util/type/use_case.dart';

typedef AddIncomeCategoryUseCase = UseCase<AddIncomeCategoryInput, Unit>;

class AddIncomeCategoryInput {
  /// User ID.
  final String uid;

  /// Name of new category.
  final String name;

  final Repository<IncomeCategory> repository;

  const AddIncomeCategoryInput({
    required this.uid,
    required this.name,
    required this.repository,
  });
}
