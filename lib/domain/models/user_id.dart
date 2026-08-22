import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_id.freezed.dart';

/// ユーザーIDの値オブジェクト
@freezed
abstract class UserId with _$UserId {
  @Assert('value.length > 0', 'ユーザーIDは1文字以上である必要があります')
  const factory UserId(String value) = _UserId;
}
