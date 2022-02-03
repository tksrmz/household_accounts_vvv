import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';
import 'package:household_accounts/util/uuid.dart';

typedef AddCategoryUseCase = UseCase<AddCategoryInput, Category>;

class AddCategoryInput extends Equatable {
  final String categoryName;
  final CategoryType type;
  final int budget;

  const AddCategoryInput(this.categoryName, this.type, this.budget);

  @override
  List<Object> get props => [categoryName, type];
}

class AddCategoryInteractor extends AddCategoryUseCase {
  final CategoryRepository _repository;

  AddCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Category>> handle(AddCategoryInput input) async {
    final category = Category(
      UUID.generate(),
      input.categoryName,
      input.type,
      input.budget,
    );
    final result = await _repository.register(category);
    return result.replace(category);
  }
}
