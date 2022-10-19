import 'package:flutter/widgets.dart';

import '../../../util/type/single_or_pair.dart';

@immutable
class UserInfo {
  const UserInfo({
    required this.uid,
    this.pairId,
  });

  final String uid;
  final String? pairId;

  bool get hasPair => pairId != null;

  String repoId(SingleOrPair value) {
    print('$UserInfo#$repoId($value)');

    final String id;
    switch (value) {
      case SingleOrPair.single:
        print('$UserInfo#$repoId: return uid $uid');
        id = uid;
        break;

      case SingleOrPair.pair:
        assert(this.hasPair, 'PairId has required, but it is null!');
        print('$UserInfo#$repoId: return pairId ${pairId!}');
        id = pairId!;
        break;
    }
    return id;
  }

  @override
  String toString() {
    return '$UserInfo(uid: $uid, pairId: $pairId';
  }
}
