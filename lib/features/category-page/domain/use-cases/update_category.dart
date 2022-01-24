import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/features/category-page/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

typedef UpdateCategoryUseCase = UseCase<UpdateCategoryInput, Category>;

class UpdateCategoryInput extends Equatable {
  final String id;
  final String? newCategoryName;
  final int? newBudget;

  const UpdateCategoryInput({
    required String id,
    String? newCategoryName,
    int? newBudget,
  })  : this.id = id,
        this.newCategoryName = newCategoryName,
        this.newBudget = newBudget;

  @override
  List<Object> get props {
    final props = <Object>[id];
    if (newCategoryName != null) {
      props.add(newCategoryName!);
    }
    if (newBudget != null) {
      props.add(newBudget!);
    }
    return props;
  }
}

class UpdateCategoryInteractor extends UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryInteractor(this._repository);

  @override
  Future<Either<Failure, Category>> handle(UpdateCategoryInput input) async {
    final failureOrCurrentValue = await _repository.retrieveById(input.id);
    final failureOrNewValue = failureOrCurrentValue.map(
      (currentValue) => Category(
        input.id,
        input.newCategoryName ?? currentValue.name,
        currentValue.type,
        input.newBudget ?? currentValue.budget,
      ),
    );

    final result =
        await failureOrNewValue.fold<Future<Either<Failure, Category>>>(
      (failure) async => Left(failure),
      (newValue) async {
        final failureOrSuccess = await _repository.update(newValue);
        return failureOrSuccess.replace(newValue);
      },
    );
    return result;
  }
}
