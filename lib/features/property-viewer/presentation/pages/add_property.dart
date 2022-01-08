import 'package:flutter/material.dart';
import 'package:household_accounts/features/property-viewer/domain/entities/property.dart';
import 'package:household_accounts/features/property-viewer/presentation/states/property_list.dart';
import 'package:provider/provider.dart';

class AddPropertyPage extends StatelessWidget {
  const AddPropertyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new property'),
      ),
      body: _PageContents(),
    );
  }
}

class _PageContents extends StatefulWidget {
  const _PageContents({Key? key}) : super(key: key);

  @override
  _PageContentsState createState() => _PageContentsState();
}

class _PageContentsState extends State<_PageContents> {
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
        // TODO: Add padding here.
        _PropertyNameTextField(
          controller: _nameController,
        ),
        // TODO: Add padding here.
        _PropertyAmountTextField(
          controller: _amountController,
        ),
        _AddButton(
          onPressed: () {
            context.read<PropertyListState>().addProperty(
                  _nameController.text,
                  _amountController.text,
                );
            Navigator.pop(context);
          },
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

class _AddButton extends StatelessWidget {
  final void Function() _onPressed;

  _AddButton({
    required void Function() onPressed,
    Key? key,
  })  : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onPressed,
      child: const Text('Add'),
    );
  }
}
