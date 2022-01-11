import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/domain/entities/identifiable.dart';
import 'package:household_accounts/util/failures/failure.dart';

/// Base class for repositories that store data of class T extending [Identifiable].
abstract class Repository<T extends Identifiable> {
  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, Unit>> register(T value);

  /// Retrieves a record that is identified by [id].
  ///
  /// Fails if no records have [id], or
  /// something goes wrong with the repository.
  Future<Either<Failure, T>> retrieveById(String id);

  /// Updates a record that is identified by [newValue.id].
  ///
  /// Fails when no records have [newValue.id],
  /// or when something goes wrong with the repository.
  Future<Either<Failure, Unit>> update(T newValue);

  /// Deletes a record that is identified by [id].
  ///
  /// Fails when something goes wrong with the repository.
  ///
  /// It's not a failure that specifying an ID that doesn't exist in the repository.
  /// Such operations do nothing.
  Future<Either<Failure, Unit>> deleteById(String id);
}
