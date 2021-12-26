import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/entity/record.dart';

/// Repository that handles [Record].
abstract class RecordRepositoryInterface {
  /// Retrieves an [Record] specified by the [id] from the repository.
  ///
  /// Returns null if the [Record] with the [id] does not exist.
  Record? retrieveById(int id);

  /// Retrieves records in the specified date range ([begin] included, [end] excluded).
  ///
  /// The records are sorted in ascending order of [Record.dateOfRecord].
  Future<List<Record>> retrieveRecordsOf(DateTime begin, DateTime end);

  /// Registers the [record] in the repository.
  ///
  /// Returns true if the registration is successful, false otherwise.
  bool register(Record record);

  /// Delete the record whose ID is [id].
  ///
  /// If such a record doesn't exist, nothing will be deleted.
  Future<void> deleteById(String id);
}

abstract class PropertyRepository {
  /// Retrieves user's properties.
  ///
  /// The list order has no meanings.
  Future<List<Property>> retrieveProperties();

  /// Updates the amount of a property whose name is [newValue.name]
  Future<void> updateProperty(Property newValue);
}