import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef AddTransferRecordUseCase = UseCase2<AddTransferRecordInput, Unit>;

class AddTransferRecordInput {
  final String uid;
  final DateTime recordDate;
  final int amount;
  final String note;
  final String srcPropertyId;
  final String destPropertyId;
  final RecordRepository<TransferRecord> repository;

  AddTransferRecordInput({
    required this.uid,
    required this.recordDate,
    required this.amount,
    required this.note,
    required this.srcPropertyId,
    required this.destPropertyId,
    required this.repository,
  });
}
