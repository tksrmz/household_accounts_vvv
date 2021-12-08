import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/use_case/uc_repository.dart';

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
