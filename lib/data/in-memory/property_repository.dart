import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/repository/property_repository.dart';
import 'package:household_accounts/util/type/exception.dart';
import 'package:household_accounts/util/type/failure.dart';

/// Although this class is not used, I won't delete this.
/// There is a chance to use this as mock in tests.
class InMemoryPropertyRepository implements PropertyRepository {
  final _repository = <Property>[
    Property('id1', 'Cash', 100),
    Property('id2', 'Bank', 200),
  ];

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    _repository.removeWhere((element) => element.id == id);
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> register(Property property) async {
    if (_repository.every((element) => element.id != property.id)) {
      _repository.add(property);
      return Right(unit);
    }

    // mock
    try {
      throw RepositoryException();
    } catch (e) {
      print(e);
      return Left(RepositoryFailure());
    }
  }

  @override
  Future<Either<Failure, List<Property>>> retrieveProperties() async {
    return Right([..._repository]);
  }

  @override
  Future<Either<Failure, Unit>> update(Property newValue) async {
    if (_repository.any((element) => element.id == newValue.id)) {
      final index =
          _repository.indexWhere((element) => element.id == newValue.id);
      _repository.setAll(index, [newValue]);
      return Right(unit);
    }

    // mock
    try {
      throw RepositoryException();
    } catch (e) {
      print(e);
      return Left(RepositoryFailure());
    }
  }

  @override
  Future<Either<Failure, Property>> retrieveById(String id) async {
    final index = _repository.indexWhere((element) => element.id == id);
    return index < 0 ? Left(RepositoryFailure()) : Right(_repository[index]);
  }
}
