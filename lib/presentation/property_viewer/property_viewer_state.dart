import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:household_accounts/entity/property_entity.dart';
import 'package:household_accounts/feature/property_deletion/delete_property_use_case.dart';
import 'package:household_accounts/feature/property_editing/update_property_use_case.dart';
import 'package:household_accounts/feature/property_register/property_register_use_case.dart';
import 'package:household_accounts/feature/property_retrieve/property_retrieve_use_case.dart';

class PropertyListState with ChangeNotifier {
  // States
  List<Property> _properties;
  bool _isLoading;
  Exception? _failure;

  // Use cases
  final RetrievePersonalPropertiesUseCase _retrievePropertiesUseCase;
  final AddPersonalPropertyUseCase _addPropertiesUseCase;
  final UpdatePersonalPropertyUseCase _updatePropertyUseCase;
  final DeletePersonalPropertyUseCase _deletePropertiesUseCase;

  PropertyListState(
    this._retrievePropertiesUseCase,
    this._addPropertiesUseCase,
    this._updatePropertyUseCase,
    this._deletePropertiesUseCase,
  )   : _properties = [],
        _isLoading = false,
        _failure = null;

  UnmodifiableListView<Property> get properties =>
      UnmodifiableListView(_properties);

  bool get isLoading => _isLoading;

  bool get hasFailure => _failure != null;

  Exception? get failure => _failure;

  Future<void> loadProperties() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final failureOrProperties = await _retrievePropertiesUseCase(
      RetrievePersonalPropertiesInput(
        // TODO: Avoid using FirebaseAuth directly here.
        uid: FirebaseAuth.instance.currentUser!.uid,
      ),
    );
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
    final input = AddPersonalPropertyInput(
      // TODO: Avoid using FirebaseAuth directly here.
      uid: FirebaseAuth.instance.currentUser!.uid,
      name: propertyName,
      amount: amount,
    );

    final failureOrProperty = await _addPropertiesUseCase(input);
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

  Future<void> updateProperty(
      String id, String newPropertyName, String newPropertyValue) async {
    _failure = null;

    // FIXME: Validate [newPropertyName] before parsing it into int.
    final nullableName = newPropertyName.isNotEmpty ? newPropertyName : null;
    // FIXME: Validate [newPropertyValue] before parsing it into int.
    final nullableAmount =
        newPropertyValue.isNotEmpty ? int.parse(newPropertyValue) : null;

    final input = UpdatePersonalPropertyInput(
      // TODO: Avoid using FirebaseAuth directly here.
      uid: FirebaseAuth.instance.currentUser!.uid,
      propertyId: id,
      name: nullableName,
      amount: nullableAmount,
    );

    final failureOrProperty = await _updatePropertyUseCase(input);
    failureOrProperty.fold(
      (failure) {
        _failure = failure;
        _properties = [];
      },
      (property) {
        print('Update ${property.toString()}');

        final index = _properties.indexWhere((element) => element.id == id);
        assert(index >= 0, '$id is not in the properties');
        _properties[index] = property;
      },
    );
    notifyListeners();
  }

  Future<void> deleteProperty(String id) async {
    _failure = null;

    final failureOrUnit = await _deletePropertiesUseCase(
      DeletePersonalPropertyInput(
        propertyId: id,
        // TODO: Avoid using FirebaseAuth directly here.
        uid: FirebaseAuth.instance.currentUser!.uid,
      ),
    );
    failureOrUnit.fold(
      (failure) {
        _failure = failure;
        _properties = [];
      },
      (_) {
        print('Delete property whose id is $id');
        _properties.removeWhere((element) => element.id == id);
      },
    );
    notifyListeners();
  }
}
