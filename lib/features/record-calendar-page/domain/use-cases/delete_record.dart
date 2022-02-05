import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:household_accounts/util/use_case.dart';

typedef DeleteRecordUseCase = UseCase<DeleteRecordInput, Unit>;

class DeleteRecordInput extends Equatable {
  final String id;

  const DeleteRecordInput(this.id);

  @override
  List<Object> get props => [id];
}
