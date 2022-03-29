import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/property-viewer/domain/repositories/property_repository.dart';
import 'package:household_accounts/util/domain/entities/property.dart';
import 'package:household_accounts/util/failures/failure.dart';

class FirebasePropertyRepository implements PropertyRepository {
  @override
  Future<Either<Failure, Unit>> deleteById(String id) {
    // TODO: implement deleteById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> register(Property value) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Property>> retrieveById(String id) {
    // TODO: implement retrieveById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Property>>> retrieveProperties() {
    // TODO: implement retrieveProperties
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> update(Property newValue) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
