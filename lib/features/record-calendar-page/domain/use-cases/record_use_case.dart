import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/features/record-calendar-page/domain/repositories/uc_repository.dart';

/// Used by controllers that wants to register [RecordRegisterInput].
abstract class RecordRegisterInputPort {
  /// Returns true if the registration is successful, false otherwise.
  bool register(Record input);
}

/// Interactor of the use case where [Record] is registered.
class RecordRegisterInputHandler implements RecordRegisterInputPort {
  /// Repository where the [RecordRegisterInput] registered.
  final RecordRepositoryInterface _repository;

  RecordRegisterInputHandler(this._repository);

  @override
  bool register(Record input) => _repository.register(input);
}

abstract class RecordDeleteUseCase {
  /// Delete the record whose ID is [id].
  ///
  /// If such a record doesn't exist, nothing will be deleted.
  Future<void> deleteById(String id);
}

class RecordDeleteInteractor implements RecordDeleteUseCase {
  /// Repository from which the record will be deleted.
  final RecordRepositoryInterface _repository;

  const RecordDeleteInteractor(this._repository);

  @override
  Future<void> deleteById(String id) async {
    _repository.deleteById(id);
  }
}