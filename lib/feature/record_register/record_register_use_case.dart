import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef AddIncomeRecordUseCase = UseCase2<AddIncomeRecordInput, IncomeRecord>;

class AddIncomeRecordInput {
  final DateTime recordDate;
  final int amount;
  final String note;
  final String categoryId;
  final String propertyId;

  AddIncomeRecordInput(
    this.recordDate,
    this.amount,
    this.note,
    this.categoryId,
    this.propertyId,
  );
}

typedef AddExpenseRecordUseCase
    = UseCase2<AddExpenseRecordInput, ExpenseRecord>;

class AddExpenseRecordInput {
  final DateTime recordDate;
  final int amount;
  final String note;
  final String categoryId;
  final String propertyId;

  AddExpenseRecordInput(
    this.recordDate,
    this.amount,
    this.note,
    this.categoryId,
    this.propertyId,
  );
}

typedef AddTransferRecordUseCase
    = UseCase2<AddTransferRecordInput, TransferRecord>;

class AddTransferRecordInput {
  final DateTime recordDate;
  final int amount;
  final String note;
  final String srcPropertyId;
  final String destPropertyId;

  AddTransferRecordInput(
    this.recordDate,
    this.amount,
    this.note,
    this.srcPropertyId,
    this.destPropertyId,
  );
}
