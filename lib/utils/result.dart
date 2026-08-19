/// 処理結果(成功/失敗)を表す型。
///
/// 公式Flutterアーキテクチャの Result パターン
/// (https://docs.flutter.dev/app-architecture/design-patterns/result) を
/// そのまま採用したもの。
/// Dart 3のsealed class + switch式による網羅性チェックだけで
/// 成功/失敗を扱えるようにする。Repositoryの単発操作はこの型を返し、
/// ViewModel(Command内)でswitchして処理する。
sealed class Result<T> {
  const Result();

  /// 成功を表す [Result] を生成する。
  const factory Result.ok(T value) = Ok._;

  /// 失敗を表す [Result] を生成する。
  const factory Result.error(Exception error) = Error._;
}

/// 処理が成功したことを表す。
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// 成功時の値。
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// 処理が失敗したことを表す。
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// 失敗時の例外。
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
