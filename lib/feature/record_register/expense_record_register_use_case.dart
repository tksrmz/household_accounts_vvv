import 'package:dartz/dartz.dart';

import '../../entity/category_entity.dart';
import '../../entity/property_entity.dart';
import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

@deprecated
typedef AddExpenseRecordUseCase = UseCase2<AddExpenseRecordInput, Unit>;

@deprecated
class AddExpenseRecordInput {
  final String uid;
  final DateTime recordDate;
  final int amount;
  final String note;
  final ExpenseCategory category;
  final Property property;
  final RecordRepository<ExpenseRecord> repository;

  AddExpenseRecordInput({
    required this.uid,
    required this.recordDate,
    required this.amount,
    required this.note,
    required this.category,
    required this.property,
    required this.repository,
  });
}
