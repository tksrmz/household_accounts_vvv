import 'package:dartz/dartz.dart';

import 'exception_or.dart';
import 'identifiable.dart';

/// Base class for repository that stores data of type [T].
///
/// [repoId] is User ID or Pair ID.
/// Use this argument to specify to which repository
/// operations are applied, personal repository or shared repository.
abstract class Repository2<T extends Identifiable> {
  /// Registers [value] to the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> register({
    required String repoId,
    required T value,
  });

  /// Retrieves a record that is identified by [id].
  ///
  /// Fails if no records have [id], or
  /// something goes wrong with the repository.
  Future<ExceptionOr<T>> retrieveById({
    required String repoId,
    required String id,
  });

  /// Retrieves all records.
  ///
  /// A repository that stores a number of records MUST NOT
  /// implement this method.
  ///
  /// The order of the returned list items is implementation dependant.
  ///
  /// Fails when something goes wrong with the repository.
  Future<ExceptionOr<List<T>>> retrieveAll({
    required String repoId,
  });

  /// Updates a record that is identified by [newValue.id].
  ///
  /// Fails when no records have [newValue.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> update({
    required String repoId,
    required T newValue,
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
