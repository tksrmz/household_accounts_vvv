import 'package:dartz/dartz.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/util/failures/failure.dart';

abstract class PropertyRepository {
  /// Registers the [property] in the repository.
  ///
  /// Fails when there is already a property that is identified by [property.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, Unit>> register(Property property);

  /// Retrieves a property that is identified by [id].
  ///
  /// Fails if no properties have [id], or
  /// something goes wrong with the repository.
  Future<Either<Failure, Property>> retrieveById(String id);

  /// Retrieves all properties.
  ///
  /// The list order has no meanings.
  /// Fails when something goes wrong with the repository.
  Future<Either<Failure, List<Property>>> retrieveProperties();

  /// Updates a property that is identified by [newValue.id].
  ///
  /// Fails when no properties have [newValue.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, Unit>> update(Property newValue);

  /// Deletes a property that is identified by [id].
  ///
  /// Fails when something goes wrong with the repository.
  Future<Either<Failure, Unit>> deleteById(String id);
}
