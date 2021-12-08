import 'package:household_accounts/entity/record.dart';
import 'package:household_accounts/use_case/uc_record_register.dart';

class RecordRegisterController {
  final RecordRegisterInputPort _inputPort;
  
  RecordRegisterController(this._inputPort);
  
  void register(Record record) => _inputPort.register(record);
}