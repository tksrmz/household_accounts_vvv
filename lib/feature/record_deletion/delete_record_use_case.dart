import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/util/type/use_case.dart';

typedef DeleteRecordUseCaseNew = UseCase2<DeleteRecordInputNew, Unit>;

class DeleteRecordInputNew extends Equatable {
  final String id;
  final RecordType type;

  const DeleteRecordInputNew(this.id, this.type);

  @override
  List<Object> get props => [id, type];
}
