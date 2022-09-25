import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';
import 'package:household_accounts/util/type/use_case.dart';
import 'package:household_accounts/util/uuid/uuid.dart';

import '../../util/type/exception_or.dart';

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

class AddIncomeRecordInteractor implements AddIncomeRecordUseCase {
  final RecordRepositoryNew _repository;

  AddIncomeRecordInteractor(this._repository);

  @override
  Future<ExceptionOr<IncomeRecord>> call(
    AddIncomeRecordInput input,
  ) async {
    final record = IncomeRecord(
      UUID.generate(),
      input.recordDate,
      input.amount,
      input.note,
      input.categoryId,
      input.propertyId,
    );
    final result = await _repository.register(record);
    return result.replace(record);
  }
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

class AddExpenseRecordInteractor implements AddExpenseRecordUseCase {
  final RecordRepositoryNew _repository;

  AddExpenseRecordInteractor(this._repository);

  @override
  Future<ExceptionOr<ExpenseRecord>> call(
    AddExpenseRecordInput input,
  ) async {
    final record = ExpenseRecord(
      UUID.generate(),
      input.recordDate,
      input.amount,
      input.note,
      input.categoryId,
      input.propertyId,
    );
    final result = await _repository.register(record);
    return result.replace(record);
  }
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

class AddTransferRecordInteractor implements AddTransferRecordUseCase {
  final RecordRepositoryNew _repository;

  AddTransferRecordInteractor(this._repository);

  @override
  Future<ExceptionOr<TransferRecord>> call(
    AddTransferRecordInput input,
  ) async {
    final record = TransferRecord(
      UUID.generate(),
      input.recordDate,
      input.amount,
      input.note,
      input.srcPropertyId,
      input.destPropertyId,
    );
    final result = await _repository.register(record);
    return result.replace(record);
  }
}
