import 'package:flutter/material.dart';

class ControlledTextField extends StatefulWidget {
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  ControlledTextField({
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ControlledTextFieldState createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<ControlledTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
    );
  }
}
