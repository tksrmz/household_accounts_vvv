import 'package:flutter/material.dart';

import '../../feature/property_register/property_register_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';
import 'property_editor.dart';

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
      body: PropertyEditor(
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
