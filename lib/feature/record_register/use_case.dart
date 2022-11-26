import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef AddRecordUseCase<T extends Record2> = UseCase2<AddRecordInput<T>, Unit>;

class AddRecordInput<T extends Record2> {
  final String uid;
  final T record;
  final RecordRepository2<T> repository;

  AddRecordInput({
    required this.uid,
    required this.record,
    required this.repository,
  });
}
