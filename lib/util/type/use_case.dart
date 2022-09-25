import 'package:dartz/dartz.dart';

import 'exception_or.dart';

/// Base class for all use cases.
///
/// Use case accepts input of type [T], then returns a value of type [Future].
///
/// The [Future] completes with [Either].
/// On success, the right hand is a value of type [R].
/// On failure, the left hand is a value of type [Exception].
///
/// All the expected failures are packed into [Either].
/// So, the returned [Future] must not fail.
/// If the [Future] fails, it means there is an unexpected error.
///
/// If [call] returns nothing in success, set [R] to [Unit].
// TODO: Rename this class as `UseCase` when all the deprecated `UseCase` class usage will be removed.
abstract class UseCase2<T, R> {
  Future<ExceptionOr<R>> call(T input);
}
