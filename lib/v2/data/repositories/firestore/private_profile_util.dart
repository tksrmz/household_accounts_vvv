import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../models/privateProfile.dart';

typedef SharedNoteRef = Map<String, dynamic>;

/// [PrivateProfile]から[SharedNoteRef]を取得する。
///
/// [PrivateProfile]が存在しない場合、または
/// [PrivateProfile.sharedNote]が存在しない場合、または
/// [PrivateProfile.sharedNote.ref]が存在しない場合、または
/// [PrivateProfile.sharedNote.ref]が[DocumentReference]でない場合、
/// それぞれ[Exception]を返す。
Either<Exception, DocumentReference<SharedNoteRef>> getSharedNoteRef(
    Either<Exception, DocumentSnapshot<PrivateProfile>> either) {
  return either
      .filter(
        (r) => r.exists && r.data() != null,
        () => Exception('PrivateProfileが存在しません'),
      )
      .map((r) => r.data()!.sharedNote)
      .filter(
        (r) => r != null,
        () => Exception('PrivateProfile.sharedNoteが存在しません'),
      )
      .map((r) => r!)
      .filter(
        (r) => r.containsKey('ref'),
        () => Exception('PrivateProfile.sharedNote.refが存在しません'),
      )
      .map((r) => r['ref']! as DocumentReference<SharedNoteRef>);
}
