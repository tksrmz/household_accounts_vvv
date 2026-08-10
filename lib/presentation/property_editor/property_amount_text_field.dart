import 'package:flutter/material.dart';

class PropertyAmountTextField extends StatelessWidget {
  const PropertyAmountTextField({TextEditingController? controller, super.key})
    : _controller = controller;

  final TextEditingController? _controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: '資産額',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }
}
