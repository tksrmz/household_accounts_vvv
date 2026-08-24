import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_id.dart';

part 'user_auth.freezed.dart';

/// 認証状態(現在サインインしているユーザー)を表すモデル。
///
/// [AuthRepository]がFirebase Authの状態を包んで返す型で、
/// サインインしていないことを[notSignIn]という具体的な値で表現し、
/// nullableにしない(呼び出し側がnullチェックを忘れる余地をなくすため)。
@freezed
abstract class UserAuth with _$UserAuth {
  const factory UserAuth({required UserId uid}) = _UserAuth;

  /// サインインしていないことを表す値。
  ///
  /// [UserId]のコンストラクタが本文で検証をthrowするため、
  /// コンパイル時定数(const)にできず`static final`で持つ。
  static final UserAuth notSignIn = UserAuth(uid: UserId('not-sign-in'));
}
