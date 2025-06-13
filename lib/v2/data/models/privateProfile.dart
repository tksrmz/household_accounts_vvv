import 'package:freezed_annotation/freezed_annotation.dart';

part 'privateProfile.freezed.dart';

@freezed
abstract class PrivateProfile with _$PrivateProfile {
  const factory PrivateProfile({
    required Map<String, dynamic>? sharedNote,
  }) = _PrivateProfile;

  /// FirestoreからのJSON変換
  factory PrivateProfile.fromJson(Map<String, dynamic> json) {
    return PrivateProfile(
      sharedNote: json['sharedNote'] as Map<String, dynamic>?,
    );
  }
}

extension PrivateProfileFirestore on PrivateProfile {
  /// Firestoreに保存するためのJSONに変換
  Map<String, dynamic> toFirestoreJson() {
    return {
      if (sharedNote != null) 'sharedNote': sharedNote,
    };
  }
}
