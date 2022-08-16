import 'package:flutter/material.dart';
import 'package:household_accounts/presentation/property_viewer/property_viewer_state.dart';
import 'package:household_accounts/presentation/property_editor/property_editor.dart';

class EditPropertyPage extends StatelessWidget {
  final PropertyListState _state;
  final String _targetPropertyId;

  const EditPropertyPage({
    required PropertyListState state,
    required String targetPropertyId,
    Key? key,
  })  : _state = state,
        _targetPropertyId = targetPropertyId,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: PropertyEditor(
        onPressed: (nameController, amountController) {
          _state.updateProperty(
            _targetPropertyId,
            nameController.text,
            amountController.text,
          );
        },
        buttonChild: const Text('Edit'),
      ),
    );
  }
}
