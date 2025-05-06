import 'package:flutter/widgets.dart';

import '../../../v2/presentation/pages/state_managements/selected_note_state.dart';

@immutable
class UserInfo {
  const UserInfo({
    required this.uid,
    this.pairId,
  });

  final String uid;
  final String? pairId;

  bool get hasPair => pairId != null;

  String repoId(SelectedNote value) {
    print('$UserInfo#$repoId($value)');

    final String id;
    switch (value) {
      case SelectedNote.personal:
        print('$UserInfo#$repoId: return uid $uid');
        id = uid;
        break;

      case SelectedNote.shared:
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
