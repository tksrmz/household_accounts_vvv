import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/util/type/repository.dart';
import 'package:household_accounts/util/type/failure.dart';

abstract class PropertyRepository extends Repository<Property> {
  /// Retrieves all properties.
  ///
  /// The list order has no meanings.
  /// Fails when something goes wrong with the repository.
  Future<Either<Failure, List<Property>>> retrieveProperties();
}
