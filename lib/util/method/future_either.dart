import 'package:dartz/dartz.dart';

Future<Either<L, R>> toFutureLeft<L, R>(L value) =>
    Future.value(value).then(left);
