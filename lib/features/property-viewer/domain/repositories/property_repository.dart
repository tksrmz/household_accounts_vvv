import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/util/failures/failure.dart';

abstract class PropertyRepository {
  /// Registers the [property] in the repository.
  ///
  /// Fails when there is already a property that is identified by [property.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, void>> register(Property property);

  /// Retrieves all properties.
  ///
  /// The list order has no meanings.
  /// Fails when something goes wrong with the repository.
  Future<Either<Failure, List<Property>>> retrieveProperties();

  /// Updates a property that is identified by [newValue.id].
  ///
  /// Fails when no properties have [newValue.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, void>> update(Property newValue);

  /// Deletes a property that is identified by [id].
  ///
  /// Fails when something goes wrong with the repository.
  Future<Either<Failure, void>> deleteById(String id);
}
