import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/util/use_case.dart';

typedef DeleteIncomeCategoryUseCase = UseCase<DeleteIncomeCategoryInput, Unit>;
typedef DeleteExpenseCategoryUseCase
    = UseCase<DeleteExpenseCategoryInput, Unit>;

class DeleteIncomeCategoryInput extends Equatable {
  final String id;

  const DeleteIncomeCategoryInput(this.id);

  @override
  List<Object> get props => [id];
}

class DeleteExpenseCategoryInput extends Equatable {
  final String id;

  const DeleteExpenseCategoryInput(this.id);

  @override
  List<Object> get props => [id];
}
