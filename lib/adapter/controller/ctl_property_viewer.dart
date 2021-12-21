import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/use_case/uc_property_viewer.dart';

class PropertyViewerController {
  final DisplayPropertiesUseCaseInterface _useCase;

  PropertyViewerController(this._useCase);

  Future<void> retrieveProperties() => _useCase.retrieveProperties();

  Future<void> updateProperty(Property newValue) =>
      _useCase.updateProperty(newValue);
}
