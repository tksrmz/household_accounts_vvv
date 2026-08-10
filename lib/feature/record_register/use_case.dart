import 'package:dartz/dartz.dart';

import '../../entity/record.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef AddRecordUseCase<T extends RecordBase> =
    UseCase<AddRecordInput<T>, Unit>;

class AddRecordInput<T extends RecordBase> {
  final String uid;
  final T record;
  final RecordRepository<T> repository;

  AddRecordInput({
    required this.uid,
    required this.record,
    required this.repository,
  });
}
