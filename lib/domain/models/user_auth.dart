import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_id.dart';

part 'user_auth.freezed.dart';

/// 認証状態を表すsealed union。
///
/// サインインしていないことを番兵値(特別なuid)ではなく
/// [UserAuthNotSignedIn]という型で表現する。両状態が流れてくる購読側
/// (認証状態のStreamなど)に、分岐の考慮を型で強制するため。
@freezed
sealed class UserAuth with _$UserAuth {
  const UserAuth._();

  /// サインイン済み。
  const factory UserAuth.signedIn(UserId uid) = UserAuthSignedIn;

  /// サインインしていない。
  const factory UserAuth.notSignedIn() = UserAuthNotSignedIn;

  /// サインイン済みユーザーのuidを返す。
  ///
  /// 認証済みでのみ到達する文脈(routerのredirectが保証する画面のViewModel等)
  /// 専用。未サインインで呼ばれるのは呼び出し側の不具合なので[StateError]で
  /// fail fastさせる。両状態が流れうる購読側では、このgetterではなく
  /// パターンマッチで分岐すること。
  UserId get signedInUid => switch (this) {
    UserAuthSignedIn(:final uid) => uid,
    UserAuthNotSignedIn() => throw StateError('サインインしていません'),
  };
}
