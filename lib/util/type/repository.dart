import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/type/identifiable.dart';

import 'exception_or.dart';

/// Base class for repositories that store data of type [T].
abstract class Repository<T extends Identifiable> {
  /// Registers the [value] in the repository.
  ///
  /// Fails when there is already a record that is identified by [value.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> register(T value);

  /// Retrieves a record that is identified by [id].
  ///
  /// Fails if no records have [id], or
  /// something goes wrong with the repository.
  Future<ExceptionOr<T>> retrieveById(String id);

  /// Updates a record that is identified by [newValue.id].
  ///
  /// Fails when no records have [newValue.id],
  /// or when something goes wrong with the repository.
  Future<ExceptionOr<Unit>> update(T newValue);

  /// Deletes a record that is identified by [id].
  ///
  /// Fails when something goes wrong with the repository.
  ///
  /// It's not a failure that specifying an ID that doesn't exist in the repository.
  /// Such operations do nothing.
  Future<ExceptionOr<Unit>> deleteById(String id);
}
