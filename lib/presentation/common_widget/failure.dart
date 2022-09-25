import 'package:flutter/material.dart';

/// Debug purpose
class FailureDisplayWidget extends StatelessWidget {
  final Exception _failure;

  const FailureDisplayWidget({required Exception failure, Key? key})
      : _failure = failure,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(_failure.toString());
  }
}
