import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef DeleteTransferRecordUseCase = UseCase2<DeleteTransferRecordInput, Unit>;

class DeleteTransferRecordInput {
  /// User ID or pair ID.
  final String uid;

  /// ID of record that will be deleted.
  final String recordId;

  /// Repository from which the record will be deleted.
  final RecordRepository<TransferRecord> repository;

  DeleteTransferRecordInput({
    required this.uid,
    required this.recordId,
    required this.repository,
  });
}
