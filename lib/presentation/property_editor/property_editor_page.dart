import 'package:flutter/material.dart';

import 'property_amount_text_field.dart';
import 'property_name_text_field.dart';

typedef PropertyEditorOnPressed = void Function(String name, int amount);

class PropertyEditorPage extends StatelessWidget {
  const PropertyEditorPage({
    required String title,
    required PropertyEditorOnPressed onSubmit,
    String? initialName,
    int? initialAmount,
    Key? key,
  })  : _title = title,
        _onPressed = onSubmit,
        _initialName = initialName,
        _initialAmount = initialAmount,
        super(key: key);

  final String _title;
  final PropertyEditorOnPressed _onPressed;
  final String? _initialName;
  final int? _initialAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: _PageBody(
        onPressed: _onPressed,
        initialName: _initialName,
        initialAmount: _initialAmount,
      ),
    );
  }
}

class _PageBody extends StatefulWidget {
  const _PageBody({
    required PropertyEditorOnPressed onPressed,
    required String? initialName,
    required int? initialAmount,
    Key? key,
  })  : _onPressed = onPressed,
        _initialName = initialName,
        _initialAmount = initialAmount,
        super(key: key);

  final PropertyEditorOnPressed _onPressed;
  final String? _initialName;
  final int? _initialAmount;

  @override
  _PageBodyState createState() => _PageBodyState();
}

class _PageBodyState extends State<_PageBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget._initialName,
    );
    _amountController = TextEditingController(
      text: widget._initialAmount?.toString(),
    );
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
            autofocus: true,
            textInputAction: TextInputAction.next,
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
            this.widget._onPressed(
                  _nameController.text,
                  int.parse(_amountController.text),
                );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
