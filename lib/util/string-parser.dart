import 'package:dartz/dartz.dart';

import 'failures/failure.dart';

extension StringParser on String {
  Either<Failure, int> tryToInt() {
    int? result = int.tryParse(this);
    return result == null ? Left(StringToIntFailure()) : Right(result);
  }
}
