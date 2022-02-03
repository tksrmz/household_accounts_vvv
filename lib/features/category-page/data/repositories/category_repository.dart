import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/domain/entities/category.dart';
import 'package:household_accounts/features/category-page/domain/repositories/category_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';

class InMemoryCategoryRepository implements CategoryRepository {
  final _repository = [
    Category('id1', 'Food', CategoryType.expense, 100),
    Category('id2', 'Transportation', CategoryType.expense, 200),
    Category('id3', 'Other', CategoryType.expense, 300),
    Category('id4', 'Salary', CategoryType.income, 400),
    Category('id5', 'Pocket Money', CategoryType.income, 500),
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
