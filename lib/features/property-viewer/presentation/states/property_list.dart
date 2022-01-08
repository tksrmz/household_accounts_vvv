import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/add_properties.dart';
import 'package:household_accounts/features/property-viewer/domain/use-cases/retrieve_properties.dart';
import 'package:household_accounts/util/failures/failure.dart';
import 'package:household_accounts/util/use_case.dart';

class PropertyListState with ChangeNotifier {
  // States
  List<Property> _properties;
  bool _isLoading;
  Failure? _failure;

  // Use cases
  final RetrievePropertiesUseCase _retrievePropertiesUseCase;
  final AddPropertiesUseCase _addPropertiesUseCase;

  PropertyListState(
    this._retrievePropertiesUseCase,
    this._addPropertiesUseCase,
  )   : _properties = [],
        _isLoading = false,
        _failure = null;

  UnmodifiableListView<Property> get properties =>
      UnmodifiableListView(_properties);

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Failure? get failure => _failure;

  Future<void> loadProperties() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final failureOrProperties =
        await _retrievePropertiesUseCase.handle(NoParam());
    failureOrProperties.fold(
      (failure) {
        _failure = failure;
        _properties = [];
      },
      (props) {
        _properties = props;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProperty(String propertyName, String initialAmount) async {
    _failure = null;

    // FIXME: Validate [initialAmount] before parsing it into int.
    final amount = int.parse(initialAmount);
    // FIXME: Validate [propertyName] before passing it to [AddPropertyInput()].
    final input = AddPropertyInput(propertyName, amount);

    final failureOrProperty = await _addPropertiesUseCase.handle(input);
    failureOrProperty.fold(
      (failure) {
        _failure = failure;
        _properties = [];
      },
      (property) {
        print('Add ${property.toString()}');
        _properties.add(property);
      },
    );
    notifyListeners();
  }
}
