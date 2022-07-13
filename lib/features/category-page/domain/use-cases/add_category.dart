import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';
import 'package:household_accounts/util/uuid.dart';

@deprecated
typedef AddCategoryUseCase = UseCase<AddCategoryInput, Category>;

typedef AddCategoryUseCase2 = UseCase<AddCategoryInput2, Unit>;

@deprecated
class AddCategoryInput extends Equatable {
  final String categoryName;
  final CategoryType type;

  // final int budget;

  const AddCategoryInput(this.categoryName, this.type /*, this.budget*/);

  @override
  List<Object> get props => [categoryName, type];
}

class AddCategoryInput2 extends Equatable {
  final String name;
  final CategoryType type;
  final int budgetAmount;

  const AddCategoryInput2({
    required this.name,
    required this.type,
    this.budgetAmount = 0,
  }) : assert(budgetAmount >= 0, 'budgetAmount has a negative value.');

  @override
  List<Object?> get props => [
        name,
        type,
        budgetAmount,
      ];

  @override
  bool? get stringify => true;
}

@deprecated
class AddCategoryInteractor extends AddCategoryUseCase {
  final CategoryRepository _repository;

  AddCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Category>> handle(AddCategoryInput input) async {
    final category = Category(
      UUID.generate(),
      input.categoryName,
      input.type,
      // input.budget,
    );
    final result = await _repository.register(category);
    return result.replace(category);
  }
}
