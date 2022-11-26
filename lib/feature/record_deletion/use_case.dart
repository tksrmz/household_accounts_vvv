import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef DeleteRecordUseCase<T extends Record2>
    = UseCase2<DeleteRecordInput<T>, Unit>;

class DeleteRecordInput<T extends Record2> {
  /// User ID or pair ID.
  final String uid;

  /// Record that will be deleted.
  final T record;

  /// Repository from which the record will be deleted.
  final RecordRepository2<T> repository;

  DeleteRecordInput({
    required this.uid,
    required this.record,
    required this.repository,
  });
}
