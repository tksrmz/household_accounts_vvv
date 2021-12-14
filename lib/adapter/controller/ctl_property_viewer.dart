import 'package:household_accounts/use_case/uc_property_viewer.dart';

class PropertyViewerController {
  final DisplayPropertiesUseCaseInterface _useCase;

  PropertyViewerController(this._useCase);

  Future<void> retrieveProperties() => _useCase.retrieveProperties();
}
