import 'package:dartz/dartz.dart';

import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef AddExpenseRecordUseCase = UseCase2<AddExpenseRecordInput, Unit>;

class AddExpenseRecordInput {
  final String uid;
  final DateTime recordDate;
  final int amount;
  final String note;
  final String categoryId;
  final String propertyId;
  final RecordRepository<ExpenseRecord> repository;

  AddExpenseRecordInput({
    required this.uid,
    required this.recordDate,
    required this.amount,
    required this.note,
    required this.categoryId,
    required this.propertyId,
    required this.repository,
  });
}
