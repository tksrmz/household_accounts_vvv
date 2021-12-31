import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/use_case/use_case.dart';

typedef CreatePropertyUseCase
    = UseCase<CreatePropertyInput, CreatePropertyOutput>;

class CreatePropertyInput {
  final String _propertyName;
  final int _initialAmount;

  CreatePropertyInput(this._propertyName, this._initialAmount);

  String get propertyName => _propertyName;

  int get initialAmount => _initialAmount;
}

class CreatePropertyOutput {
  final Property? _property;

  CreatePropertyOutput(this._property);

  /// Instance of newly created Property.
  ///
  /// If failed, this value will be null.
  Property? get property => _property;
}
