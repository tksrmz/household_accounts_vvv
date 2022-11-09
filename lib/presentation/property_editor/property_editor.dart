import 'package:flutter/material.dart';
import 'package:household_accounts/entity/property_entity.dart';

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
          child: _PropertyNameTextField(
            controller: _nameController,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _PropertyAmountTextField(
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

class _PropertyNameTextField extends StatelessWidget {
  final TextEditingController _controller;

  const _PropertyNameTextField({
    required TextEditingController controller,
    Key? key,
  })  : _controller = controller,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Property name',
        helperText: '1-20 alphabet characters only',
        counterText: '0 characters',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      autofocus: true,
      maxLength: Property.maxNameLength,
    );
  }
}

class _PropertyAmountTextField extends StatelessWidget {
  final TextEditingController _controller;

  const _PropertyAmountTextField({
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
