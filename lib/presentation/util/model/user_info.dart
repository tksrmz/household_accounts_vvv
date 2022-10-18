import 'package:flutter/widgets.dart';

@immutable
class UserInfo {
  const UserInfo({
    required this.uid,
    this.pairId,
  });

  final String uid;
  final String? pairId;

  bool get hasPair => pairId != null;
}
