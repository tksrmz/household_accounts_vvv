import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';

/// Although this class is not used, I won't delete this.
/// There is a chance to use this as mock in tests.
class InMemoryCategoryRepository implements CategoryRepository {
  final _repository = [
    Category('id1', 'Food', CategoryType.expense /*, 100*/),
    Category('id2', 'Transportation', CategoryType.expense /*, 200*/),
    Category('id3', 'Other', CategoryType.expense /*, 300*/),
    Category('id4', 'Salary', CategoryType.income /*, 400*/),
    Category('id5', 'Pocket Money', CategoryType.income /*, 500*/),
  ];

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    _repository.removeWhere((element) => element.id == id);
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(Category value) async {
    if (_repository.every((element) => element.id != value.id)) {
      _repository.add(value);
      return Right(unit);
    }

    return Left(RepositoryFailure());
  }

  @override
  Future<Either<Failure, Category>> retrieveById(String id) async {
    final index = _repository.indexWhere((element) => element.id == id);
    return index >= 0 ? Right(_repository[index]) : Left(RepositoryFailure());
  }

  @override
  Future<Either<Failure, List<Category>>> retrieveCategories() async {
    return Right([..._repository]);
  }

  @override
  Future<Either<Failure, Unit>> update(Category newValue) async {
    if (_repository.any((element) => element.id == newValue.id)) {
      final index =
          _repository.indexWhere((element) => element.id == newValue.id);
      _repository[index] = newValue;
      return Right(unit);
    }

    return Left(RepositoryFailure());
  }
}

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
  Future<Either<Failure, Unit>> deleteById(String id) async {
    _repository.removeWhere((element) => element.id == id);
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(IncomeCategory value) async {
    if (_repository.every((element) => element.id != value.id)) {
      _repository.add(value);
      return Right(unit);
    }

    return Left(RepositoryFailure());
  }

  @override
  Future<Either<Failure, IncomeCategory>> retrieveById(String id) async {
    final index = _repository.indexWhere((element) => element.id == id);
    return index >= 0 ? Right(_repository[index]) : Left(RepositoryFailure());
  }

  @override
  Future<Either<Failure, List<IncomeCategory>>>
      retrieveIncomeCategories() async {
    return Right([..._repository]);
  }

  @override
  Future<Either<Failure, Unit>> update(IncomeCategory newValue) async {
    if (_repository.any((element) => element.id == newValue.id)) {
      final index =
          _repository.indexWhere((element) => element.id == newValue.id);
      _repository[index] = newValue;
      return Right(unit);
    }

    return Left(RepositoryFailure());
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
  Future<Either<Failure, Unit>> deleteById(String id) async {
    _repository.removeWhere((element) => element.id == id);
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(ExpenseCategory value) async {
    if (_repository.every((element) => element.id != value.id)) {
      _repository.add(value);
      return Right(unit);
    }

    return Left(RepositoryFailure());
  }

  @override
  Future<Either<Failure, ExpenseCategory>> retrieveById(String id) async {
    final index = _repository.indexWhere((element) => element.id == id);
    return index >= 0 ? Right(_repository[index]) : Left(RepositoryFailure());
  }

  @override
  Future<Either<Failure, List<ExpenseCategory>>>
      retrieveExpenseCategories() async {
    return Right([..._repository]);
  }

  @override
  Future<Either<Failure, Unit>> update(ExpenseCategory newValue) async {
    if (_repository.any((element) => element.id == newValue.id)) {
      final index =
          _repository.indexWhere((element) => element.id == newValue.id);
      _repository[index] = newValue;
      return Right(unit);
    }

    return Left(RepositoryFailure());
  }
}
