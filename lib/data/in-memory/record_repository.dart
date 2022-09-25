import 'package:dartz/dartz.dart';
import 'package:household_accounts/entity/record_entity.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';

import '../../util/type/exception_or.dart';

/// Although this class is not used, I won't delete this.
/// There is a chance to use this as mock in tests.
class InMemoryRecordRepository implements RecordRepositoryNew {
  @override
  Future<ExceptionOr<Unit>> register(Record value) async {
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<Unit>> deleteById(String id, RecordType type) async {
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<Record>> retrieveById(
    String id,
    RecordType type,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ExceptionOr<List<Record>>> retrieveRecordsOf(
    DateTime begin,
    DateTime end,
  ) async {
    throw UnimplementedError();
  }
}
