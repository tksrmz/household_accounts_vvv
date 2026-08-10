import 'package:dartz/dartz.dart';

import '../../entity/record.dart';
import '../../util/type/exception_or.dart';
import 'use_case.dart';

class DeleteRecordInteractor<T extends RecordBase>
    implements DeleteRecordUseCase<T> {
  @override
  Future<ExceptionOr<Unit>> call(DeleteRecordInput<T> input) =>
      input.repository.deleteById(repoId: input.uid, id: input.record.id);
}
