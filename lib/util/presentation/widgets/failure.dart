import 'package:flutter/material.dart';
import 'package:household_accounts/util/failures/failure.dart';

/// Debug purpose
class FailureDisplayWidget extends StatelessWidget {
  final Failure _failure;

  const FailureDisplayWidget({required Failure failure, Key? key})
      : _failure = failure,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(_failure.toString());
  }
}
