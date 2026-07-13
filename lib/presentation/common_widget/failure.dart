import 'package:flutter/material.dart';

/// Debug purpose
class FailureDisplayWidget extends StatelessWidget {
  final Exception _failure;

  const FailureDisplayWidget({required Exception failure, super.key})
      : _failure = failure;

  @override
  Widget build(BuildContext context) {
    return Text(_failure.toString());
  }
}
