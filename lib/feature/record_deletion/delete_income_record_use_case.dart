import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

@deprecated
typedef DeleteIncomeRecordUseCase = UseCase2<DeleteIncomeRecordInput, Unit>;

@deprecated
class DeleteIncomeRecordInput {
  /// User ID or pair ID.
  final String uid;

  /// ID of record that will be deleted.
  final String recordId;

  /// Repository from which the record will be deleted.
  final RecordRepository<IncomeRecord> repository;

  DeleteIncomeRecordInput({
    required this.uid,
    required this.recordId,
    required this.repository,
  });
}
