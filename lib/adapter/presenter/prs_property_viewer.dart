import 'package:flutter/widgets.dart';
import 'package:household_accounts/entity/property.dart';
import 'package:household_accounts/use_case/uc_property_viewer.dart';

class _PropertyViewerViewModel {
  late List<Property> _properties;

  _PropertyViewerViewModel(this._properties);

  _PropertyViewerViewModel.empty() : this([]);

  List<Property> get properties => [..._properties];

  void update(List<Property> properties) {
    _properties = properties;
  }
}

class PropertyViewerPresenter
    with ChangeNotifier
    implements PropertyViewerPresenterInterface {
  final _PropertyViewerViewModel _viewModel = _PropertyViewerViewModel.empty();

  _PropertyViewerViewModel get viewModel => _viewModel;

  @override
  void display(PropertyViewerOutputData outputData) {
    _viewModel.update(outputData.properties);
    notifyListeners();
  }
}
