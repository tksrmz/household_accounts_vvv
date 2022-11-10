import 'package:flutter/material.dart';

class PropertyAmountTextField extends StatelessWidget {
  const PropertyAmountTextField({
    TextEditingController? controller,
    Key? key,
  })  : _controller = controller,
        super(key: key);

  final TextEditingController? _controller;

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
