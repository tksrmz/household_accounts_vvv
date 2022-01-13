import 'package:flutter/material.dart';

class DeleteIconButton extends StatelessWidget {
  final void Function() _onPressed;
  final Icon _icon;

  const DeleteIconButton(
      {required void Function() onPressed,
      Icon icon = const Icon(Icons.delete),
      Key? key})
      : _onPressed = onPressed,
        _icon = icon,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _onPressed,
      icon: _icon,
    );
  }
}
