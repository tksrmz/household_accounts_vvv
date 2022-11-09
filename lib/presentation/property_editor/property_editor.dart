import 'package:flutter/material.dart';

import 'property_name_text_field.dart';

typedef PropertyNameAndAmountHandler = void Function(
  TextEditingController,
  TextEditingController,
);

class PropertyEditor extends StatefulWidget {
  final PropertyNameAndAmountHandler _onPressed;
  final Widget _buttonChild;

  const PropertyEditor({
    required PropertyNameAndAmountHandler onPressed,
    required Widget buttonChild,
    Key? key,
  })  : _onPressed = onPressed,
        _buttonChild = buttonChild,
        super(key: key);

  @override
  _PropertyEditorState createState() => _PropertyEditorState();
}

class _PropertyEditorState extends State<PropertyEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PropertyNameTextField(
            controller: _nameController,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PropertyAmountTextField(
            controller: _amountController,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            this.widget._onPressed(_nameController, _amountController);
            Navigator.pop(context);
          },
          child: this.widget._buttonChild,
        ),
      ],
    );
  }
}

class PropertyAmountTextField extends StatelessWidget {
  final TextEditingController _controller;

  const PropertyAmountTextField({
    required TextEditingController controller,
    Key? key,
  })  : _controller = controller,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }
}
