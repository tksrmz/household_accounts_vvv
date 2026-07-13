import 'package:flutter/material.dart';

import '../../entity/property.dart';

class PropertyNameTextField extends StatelessWidget {
  const PropertyNameTextField({
    this.controller,
    this.autofocus = false,
    this.textInputAction,
    super.key,
  });

  final TextEditingController? controller;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '資産名',
        helperText: '1文字以上${Property.maxNameLength}文字以内',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      autofocus: autofocus,
      maxLength: Property.maxNameLength,
      textInputAction: textInputAction,
    );
  }
}
