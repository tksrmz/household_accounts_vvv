// 旧app_home_pageのペア検知StreamBuilderの一時移植。
// PR2でProfileRepository.watchPairStatus()へ置換して本ファイルごと削除する。

import 'package:cloud_firestore/cloud_firestore.dart';

/// `privateProfiles/{uid}` を購読し、ペアの共有ノートIDを流す。
///
/// ペアがいない場合は `null` を流す。
Stream<String?> watchPrivateProfilePairId(
  FirebaseFirestore firestore,
  String uid,
) {
  return firestore
      .doc('privateProfiles/$uid')
      .snapshots()
      // doc未作成(サインアップ直後)はemitせずローディング維持
      .where((snapshot) => snapshot.exists)
      .map((snapshot) {
        final sharedNote =
            snapshot.data()?['sharedNote'] as Map<String, dynamic>?;
        if (sharedNote == null) {
          return null;
        }
        return (sharedNote['ref'] as DocumentReference).id;
      });
}
