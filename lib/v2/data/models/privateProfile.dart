import 'package:freezed_annotation/freezed_annotation.dart';

part 'privateProfile.freezed.dart';
part 'privateProfile.g.dart';

@freezed
abstract class PrivateProfile with _$PrivateProfile {
  const factory PrivateProfile({
    required Map<String, dynamic>? sharedNote,
  }) = _PrivateProfile;

  factory PrivateProfile.fromJson(Map<String, dynamic> json) =>
      _$PrivateProfileFromJson(json);
}
