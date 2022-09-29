import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/category_entity.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';

import '../../util/type/exception_or.dart';

/// Although this class is not used, I won't delete this.
/// There is a chance to use this as mock in tests.
class InMemoryIncomeCategoryRepository implements IncomeCategoryRepository {
  final _repository = [
    IncomeCategory(
      id: 'id0',
      name: 'Salary',
    ),
    IncomeCategory(
      id: 'id1',
      name: 'Pocket Money',
    ),
    IncomeCategory(
      id: 'id2',
      name: 'Other',
    ),
  ];

  @override
  Future<ExceptionOr<Unit>> deleteById(String id) async {
    _repository.removeWhere((element) => element.id == id);
    return Right(unit);
  }

  @override
  Future<ExceptionOr<Unit>> register(IncomeCategory value) async {
    if (_repository.every((element) => element.id != value.id)) {
      _repository.add(value);
      return Right(unit);
    }

    return Left(Exception('dummy'));
  }

  @override
  Future<ExceptionOr<IncomeCategory>> retrieveById(String id) async {
    final index = _repository.indexWhere((element) => element.id == id);
    return index >= 0 ? Right(_repository[index]) : Left(Exception('dummy'));
  }

  @override
  Future<ExceptionOr<List<IncomeCategory>>> retrieveAll() async {
    return Right([..._repository]);
  }

  @override
  Future<ExceptionOr<Unit>> update(IncomeCategory newValue) async {
    if (_repository.any((element) => element.id == newValue.id)) {
      final index =
          _repository.indexWhere((element) => element.id == newValue.id);
      _repository[index] = newValue;
      return Right(unit);
    }

    return Left(Exception('dummy'));
  }
}

/// Although this class is not used, I won't delete this.
/// There is a chance to use this as mock in tests.
class InMemoryExpenseCategoryRepository implements ExpenseCategoryRepository {
  final _repository = [
    ExpenseCategory(
      id: 'id1',
      name: 'Food',
      totalBudget: 1000,
    ),
    ExpenseCategory(
      id: 'id2',
      name: 'Transportation',
      totalBudget: 2000,
    ),
    ExpenseCategory(
      id: 'id3',
      name: 'Other',
      totalBudget: 3000,
    ),
  ];

  @override
  Future<ExceptionOr<Unit>> deleteById(String id) async {
    _repository.removeWhere((element) => element.id == id);
    return Right(unit);
  }

  @override
  Future<ExceptionOr<Unit>> register(ExpenseCategory value) async {
    if (_repository.every((element) => element.id != value.id)) {
      _repository.add(value);
      return Right(unit);
    }

    return Left(Exception('dummy'));
  }

  @override
  Future<ExceptionOr<ExpenseCategory>> retrieveById(String id) async {
    final index = _repository.indexWhere((element) => element.id == id);
    return index >= 0 ? Right(_repository[index]) : Left(Exception('dummy'));
  }

  @override
  Future<ExceptionOr<List<ExpenseCategory>>> retrieveAll() async {
    return Right([..._repository]);
  }

  @override
  Future<ExceptionOr<Unit>> update(ExpenseCategory newValue) async {
    if (_repository.any((element) => element.id == newValue.id)) {
      final index =
          _repository.indexWhere((element) => element.id == newValue.id);
      _repository[index] = newValue;
      return Right(unit);
    }

    return Left(Exception('dummy'));
  }
}
