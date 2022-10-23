import 'package:flutter/material.dart';

import '../../feature/property_editing/update_property_use_case.dart';
import '../../util/service_locator/main.dart';
import '../../util/type/single_or_pair.dart';
import '../util/model/user_info.dart';
import '../util/repository_selector.dart';
import 'property_editor.dart';

class EditPropertyPage extends StatelessWidget {
  final String _targetPropertyId;
  final SingleOrPair _singleOrPair;
  final UserInfo _userInfo;

  const EditPropertyPage({
    required String targetPropertyId,
    required SingleOrPair singleOrPair,
    required UserInfo userInfo,
    Key? key,
  })  : _singleOrPair = singleOrPair,
        _userInfo = userInfo,
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
          final name = nameController.text;
          final amountString = amountController.text;
          final input = _generateInput(
            name: name.isNotEmpty ? name : null,
            amount: amountString.isNotEmpty ? int.parse(amountString) : null,
          );
          final update = sl<UpdatePropertyUseCase>();
          update(input);
        },
        buttonChild: const Text('Edit'),
      ),
    );
  }

  UpdatePropertyInput _generateInput({
    required String? name,
    required int? amount,
  }) =>
      UpdatePropertyInput(
        uid: _userInfo.repoId(_singleOrPair),
        propertyId: _targetPropertyId,
        name: name,
        amount: amount,
        repository: selectPropertyRepository(_singleOrPair),
      );
}
