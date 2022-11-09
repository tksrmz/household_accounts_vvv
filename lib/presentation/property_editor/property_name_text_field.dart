import 'package:flutter/material.dart';

import '../../entity/property_entity.dart';

class PropertyNameTextField extends StatelessWidget {
  final TextEditingController _controller;

  const PropertyNameTextField({
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
