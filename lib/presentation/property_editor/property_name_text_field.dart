import 'package:flutter/material.dart';

import '../../entity/property_entity.dart';

class PropertyNameTextField extends StatelessWidget {
  const PropertyNameTextField({
    this.controller,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  final TextEditingController? controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Property name',
        helperText: '1-${Property.maxNameLength} characters only',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      autofocus: autofocus,
      maxLength: Property.maxNameLength,
    );
  }
}
