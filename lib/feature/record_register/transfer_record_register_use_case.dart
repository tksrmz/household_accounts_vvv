import 'package:dartz/dartz.dart';

import '../../entity/property_entity.dart';
import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

@deprecated
typedef AddTransferRecordUseCase = UseCase2<AddTransferRecordInput, Unit>;

@deprecated
class AddTransferRecordInput {
  final String uid;
  final DateTime recordDate;
  final int amount;
  final String note;
  final Property source;
  final Property destination;
  final RecordRepository<TransferRecord> repository;

  AddTransferRecordInput({
    required this.uid,
    required this.recordDate,
    required this.amount,
    required this.note,
    required this.source,
    required this.destination,
    required this.repository,
  });
}
