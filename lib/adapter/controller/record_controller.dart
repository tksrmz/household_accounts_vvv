import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/use_case/record_use_case.dart';

class RecordRegisterController {
  final RecordRegisterInputPort _inputPort;

  RecordRegisterController(this._inputPort);

  void register(Record record) => _inputPort.register(record);
}

class RecordDeleteController {
  final RecordDeleteUseCase _useCase;

  const RecordDeleteController(this._useCase);

  Future<void> deleteById(String id) async => _useCase.deleteById(id);
}
