import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef UpdateIncomeCategoryUseCase = UseCase2<UpdateIncomeCategoryInput, Unit>;
typedef UpdateExpenseCategoryUseCase
    = UseCase2<UpdateExpenseCategoryInput, Unit>;

class UpdateIncomeCategoryInput extends Equatable {
  final IncomeCategory original;
  final String? newName;

  const UpdateIncomeCategoryInput({
    required this.original,
    this.newName,
  });

  @override
  List<Object?> get props => [
        ...original.props,
        newName,
      ];
}

class UpdateExpenseCategoryInput extends Equatable {
  final ExpenseCategory original;
  final String? newName;
  final int? newBudgetAmount;

  const UpdateExpenseCategoryInput({
    required this.original,
    this.newName,
    this.newBudgetAmount,
  });

  @override
  List<Object?> get props => [
        ...original.props,
        newName,
        newBudgetAmount,
      ];
}
