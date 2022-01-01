import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/features/property-viewer/domain/repositories/property_repository.dart';
import 'package:household_accounts/util/failures/exception.dart';
import 'package:household_accounts/util/failures/failure.dart';

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
}
