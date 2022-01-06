import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
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

  PropertyListState(
    this._retrievePropertiesUseCase,
  )   : _properties = [],
        _isLoading = false,
        _failure = null;

  UnmodifiableListView get properties => UnmodifiableListView(_properties);

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
}
