import 'package:flutter/material.dart';

import 'property_amount_text_field.dart';
import 'property_name_text_field.dart';

typedef PropertyEditorOnSubmit = void Function(String name, int amount);

class PropertyEditorPage extends StatelessWidget {
  const PropertyEditorPage({
    required String title,
    required PropertyEditorOnSubmit onSubmit,
    String? initialName,
    int? initialAmount,
    super.key,
  }) : _title = title,
       _onSubmit = onSubmit,
       _initialName = initialName,
       _initialAmount = initialAmount;

  final String _title;
  final PropertyEditorOnSubmit _onSubmit;
  final String? _initialName;
  final int? _initialAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _PageBody(
        onSubmit: _onSubmit,
        initialName: _initialName,
        initialAmount: _initialAmount,
      ),
    );
  }
}

class _PageBody extends StatefulWidget {
  const _PageBody({
    required PropertyEditorOnSubmit onSubmit,
    required String? initialName,
    required int? initialAmount,
  }) : _onSubmit = onSubmit,
       _initialName = initialName,
       _initialAmount = initialAmount;

  final PropertyEditorOnSubmit _onSubmit;
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
    _nameController = TextEditingController(text: widget._initialName);
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
          child: PropertyAmountTextField(controller: _amountController),
        ),
        ElevatedButton(
          onPressed: () {
            widget._onSubmit(
              _nameController.text,
              int.parse(_amountController.text),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
