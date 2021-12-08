import 'package:household_accounts/entity/record.dart';

/// Repository that handles [Record].
abstract class RecordRepositoryInterface {
  /// Retrieves an [Record] specified by the [id] from the repository.
  ///
  /// Returns null if the [Record] with the [id] does not exist.
  Record? retrieveById(int id);

  /// Registers the [record] in the repository.
  ///
  /// Returns true if the registration is successful, false otherwise.
  bool register(Record record);
}