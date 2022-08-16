import 'package:flutter/material.dart';
import 'package:household_accounts/presentation/property_viewer/property_viewer_state.dart';
import 'package:household_accounts/presentation/property_editor/property_editor.dart';

class AddPropertyPage extends StatelessWidget {
  final PropertyListState _state;

  const AddPropertyPage({required PropertyListState state, Key? key})
      : _state = state,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new property'),
      ),
      body: PropertyEditor(
        onPressed: (nameController, amountController) {
          _state.addProperty(
            nameController.text,
            amountController.text,
          );
        },
        buttonChild: const Text('Add'),
      ),
    );
  }
}
