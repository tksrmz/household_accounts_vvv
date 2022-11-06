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

  /// Input to retrieve records.
  ///
  /// If [day] is null, the use case will retrieve records in [month].
  /// If not, it will retrieve records on [day].
  RetrieveRecordsInput({
    required this.uid,
    required this.year,
    required this.month,
    this.day,
    required this.repository,
  });
}
