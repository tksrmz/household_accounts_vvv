import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'failures/failure.dart';

/// Base class for all use cases.
///
/// Use case accepts input class T, then returns output of Future<Either<Failure, R>>.
abstract class UseCase<T, R> {
  Future<Either<Failure, R>> handle(T input);
}

/// Class for use cases that have no input and/or output.
class NoParam extends Equatable {
  List<Object> get props => const [];
}
