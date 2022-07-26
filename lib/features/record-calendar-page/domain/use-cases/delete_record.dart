import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/util/use_case.dart';
import 'package:household_accounts/features/input-page/domain/entities/record.dart';

typedef DeleteRecordUseCaseNew = UseCase<DeleteRecordInputNew, Unit>;

class DeleteRecordInputNew extends Equatable {
  final String id;
  final RecordType type;

  const DeleteRecordInputNew(this.id, this.type);

  @override
  List<Object> get props => [id, type];
}
