import 'package:dartz/dartz.dart';

import '../../entity/record.dart';
import '../../util/type/exception_or.dart';
import 'use_case.dart';

class AddRecordInteractor<T extends RecordBase> implements AddRecordUseCase<T> {
  @override
  Future<ExceptionOr<Unit>> call(AddRecordInput<T> input) =>
      input.repository.register(repoId: input.uid, value: input.record);
}
