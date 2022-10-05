import '../../entity/record_entity.dart';
import '../../util/type/use_case.dart';
import '../repository/record_repository.dart';

typedef RetrieveRecordsUseCase<T extends Record>
    = UseCase2<RetrieveRecordsInput<T>, List<T>>;

class RetrieveRecordsInput<T extends Record> {
  /// User ID or pair ID.
  final String uid;

  /// Year of retrieved records.
  final int year;

  /// Month of retrieved records.
  final int? month;

  /// Day of retrieved records.
  final int? day;

  /// Repository from which records are retrieved.
  final RecordRepository<T> repository;

  /// Input to retrieve records in [year].
  RetrieveRecordsInput.year({
    required this.uid,
    required this.year,
    required this.repository,
  })  : month = null,
        day = null;

  /// Input to retrieve records of [month] in [year].
  RetrieveRecordsInput.month({
    required this.uid,
    required this.year,
    required this.month,
    required this.repository,
  }) : day = null;

  /// Input to retrieve records on [day] of [month] in [year].
  RetrieveRecordsInput.day({
    required this.uid,
    required this.year,
    required this.month,
    required this.day,
    required this.repository,
  });
}
