import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';
import 'package:household_accounts/features/input-page/domain/repositories/record_repository.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';
import 'package:household_accounts/util/uuid.dart';

typedef AddRecordUseCase = UseCase<AddRecordInput, RecordOld>;

class AddRecordInput extends Equatable {
  final DateTime dateOfRecord;
  final int amount;
  final String note;
  final String categoryId;

  AddRecordInput(this.dateOfRecord, this.amount, this.note, this.categoryId);

  @override
  List<Object> get props => [dateOfRecord, amount, note, categoryId];
}

class AddRecordInteractor extends AddRecordUseCase {
  final RecordRepositoryOld _repository;

  AddRecordInteractor(this._repository);

  @override
  Future<Either<Failure, RecordOld>> handle(AddRecordInput input) async {
    final record = RecordOld(
      UUID.generate(),
      DateTime.now(),
      input.dateOfRecord,
      input.amount,
      input.note,
      input.categoryId,
    );
    final result = await _repository.register(record);
    return result.replace(record);
  }
}

typedef AddIncomeRecordUseCase = UseCase<AddIncomeRecordInput, IncomeRecord>;

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
  final RecordRepository _repository;

  AddIncomeRecordInteractor(this._repository);

  @override
  Future<Either<Failure, IncomeRecord>> handle(
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
