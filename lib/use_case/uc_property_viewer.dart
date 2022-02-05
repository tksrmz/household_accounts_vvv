import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/features/record-calendar-page/domain/repositories/uc_repository.dart';

abstract class DisplayPropertiesUseCaseInterface {
  /// Retrieves properties of the user.
  Future<void> retrieveProperties();

  /// Updates the amount of a property whose name is [newValue.name]
  Future<void> updateProperty(Property newValue);
}

class PropertyViewerOutputData {
  final List<Property> _properties;

  PropertyViewerOutputData(this._properties);

  List<Property> get properties => _properties;
}

abstract class PropertyViewerPresenterInterface {
  void display(PropertyViewerOutputData outputData);
}

class DisplayPropertiesInteractor implements DisplayPropertiesUseCaseInterface {
  final PropertyRepository _repository;
  final PropertyViewerPresenterInterface _presenter;

  const DisplayPropertiesInteractor(this._repository, this._presenter);

  @override
  Future<void> retrieveProperties() async {
    _repository.retrieveProperties().then((properties) =>
        _presenter.display(PropertyViewerOutputData(properties)));
  }

  @override
  Future<void> updateProperty(Property property) async {
    _repository.updateProperty(property);
  }
}
