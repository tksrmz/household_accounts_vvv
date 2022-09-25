import 'package:dartz/dartz.dart';
import 'package:household_accounts/feature/category_deletion/delete_category_use_case.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';

import '../../util/type/exception_or.dart';

class DeleteIncomeCategoryInteractor extends DeleteIncomeCategoryUseCase {
  final IncomeCategoryRepository _repository;

  DeleteIncomeCategoryInteractor(this._repository);

  @override
  Future<ExceptionOr<Unit>> call(DeleteIncomeCategoryInput input) =>
      _repository.deleteById(input.id);
}

class DeleteExpenseCategoryInteractor extends DeleteExpenseCategoryUseCase {
  final ExpenseCategoryRepository _repository;

  DeleteExpenseCategoryInteractor(this._repository);

  @override
  Future<ExceptionOr<Unit>> call(DeleteExpenseCategoryInput input) =>
      _repository.deleteById(input.id);
}
