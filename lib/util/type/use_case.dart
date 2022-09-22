import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'exception_or.dart';
import 'failure.dart';

/// Base class for all use cases.
///
/// Use case accepts input class T, then returns output of Future<Either<Failure, R>>.
/// If UseCase.handle returns nothing in success, set R to Unit.
@Deprecated('Use `UseCase2<T,R>` instead')
abstract class UseCase<T, R> {
  Future<Either<Failure, R>> handle(T input);
}

/// Class for use cases that have no input and/or output.
@Deprecated('`Unit` class from dartz lib is enough')
class NoParam extends Equatable {
  const NoParam();

  List<Object> get props => const [];
}

@Deprecated('`unit` from dartz lib is enough')
const NoParam noparam = const NoParam();

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
