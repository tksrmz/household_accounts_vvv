import 'package:flutter/material.dart';

import '../../feature/property_register/property_register_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';
import 'property_amount_text_field.dart';
import 'property_editor.dart';
import 'property_name_text_field.dart';

class AddPropertyPage extends StatelessWidget {
  const AddPropertyPage({
    required SingleOrPair singleOrPair,
    required UserInfo userInfo,
    Key? key,
  })  : _singleOrPair = singleOrPair,
        _userInfo = userInfo,
        super(key: key);

  final SingleOrPair _singleOrPair;
  final UserInfo _userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new property'),
      ),
      body: _PageBody(
        onPressed: (nameController, amountController) {
          final input = _generateInput(
            name: nameController.text,
            amount: int.parse(amountController.text),
          );
          final register = sl<AddPropertyUseCase>();
          register(input);
        },
        buttonChild: const Text('Add'),
      ),
    );
  }

  AddPropertyInput _generateInput({
    required String name,
    required int amount,
  }) =>
      AddPropertyInput(
        uid: _userInfo.repoId(_singleOrPair),
        name: name,
        amount: amount,
        repository: selectPropertyRepository(_singleOrPair),
      );
}

class _PageBody extends StatefulWidget {
  final PropertyNameAndAmountHandler _onPressed;
  final Widget _buttonChild;

  const _PageBody({
    required PropertyNameAndAmountHandler onPressed,
    required Widget buttonChild,
    Key? key,
  })  : _onPressed = onPressed,
        _buttonChild = buttonChild,
        super(key: key);

  @override
  _PageBodyState createState() => _PageBodyState();
}

class _PageBodyState extends State<_PageBody> {
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
            this.widget._onPressed(_nameController, _amountController);
            Navigator.pop(context);
          },
          child: this.widget._buttonChild,
        ),
      ],
    );
  }
}
