import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../util/type/exception_or.dart';

@Deprecated('Use PropertyRepository2 instead.')
abstract class PropertyRepository {
  /// Retrieves all properties.
  ///
  /// The list order has no meanings.
  /// Fails when something goes wrong with the repository.
  // TODO: Rename this method to `retrieveAll`
  Future<ExceptionOr<List<Property>>> retrieveProperties();

  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> register(Property value);

  /// Retrieves a record that is identified by [id].
  ///
  /// Fails if no records have [id], or
  /// something goes wrong with the repository.
  Future<ExceptionOr<Property>> retrieveById(String id);

  /// Updates a record that is identified by [newValue.id].
  ///
  /// Fails when no records have [newValue.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> update(Property newValue);

  /// Deletes a record that is identified by [id].
  ///
  /// Fails when something goes wrong with the repository.
  ///
  /// It's not a failure that specifying an ID that doesn't exist in the repository.
  /// Such operations do nothing.
  Future<ExceptionOr<Unit>> deleteById(String id);
}

/// Base class for repository that stores property.
///
/// [repoId] is User ID or Pair ID.
/// Use this argument to specify to which repository
/// operations are applied, personal repository or shared repository.
abstract class PropertyRepository2 {
  /// Retrieves all properties.
  ///
  /// The list order has no meanings.
  /// Fails when something goes wrong with the repository.
  Future<ExceptionOr<List<Property>>> retrieveAll({
    required String repoId,
  });

  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required Property value,
  });

  /// Retrieves a record that is identified by [id].
  ///
  /// Fails if no records have [id], or
  /// something goes wrong with the repository.
  Future<ExceptionOr<Property>> retrieveById({
    required String repoId,
    required String id,
  });

  /// Updates a record that is identified by [newValue.id].
  ///
  /// Fails when no records have [newValue.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required Property newValue,
  });

  /// Deletes a record that is identified by [id].
  ///
  /// Fails when something goes wrong with the repository.
  ///
  /// It's not a failure that specifying an ID that doesn't exist in the repository.
  /// Such operations do nothing.
  Future<ExceptionOr<Unit>> deleteById({
    required String repoId,
    required String id,
  });
}
