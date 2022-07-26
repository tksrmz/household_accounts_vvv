import 'package:dartz/dartz.dart';
import 'package:household_accounts/util/failures/failure.dart';

typedef FailureOr<T> = Either<Failure, T>;
