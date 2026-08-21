import 'package:flutter/foundation.dart';

import 'result.dart';

/// 引数を取らないアクションの型。[Command0] が実行する。
typedef CommandAction0<T> = Future<Result<T>> Function();

/// 引数を1つ取るアクションの型。[Command1] が実行する。
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// ユーザー操作起点の非同期処理を実行状態ごと包む基底クラス。
///
/// 公式Flutterアーキテクチャの Command パターン
/// (https://docs.flutter.dev/app-architecture/design-patterns/command) を
/// そのまま採用したもの。実行中/完了/エラーをChangeNotifierとして
/// 公開するため、Viewは `ListenableBuilder` 等でそのまま購読できる。
/// 結果は [Result] で保持するため、例外を投げずにViewModelまで届く。
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;

  /// アクションを実行中かどうか。
  bool get running => _running;

  Result<T>? _result;

  /// 直近の実行結果。未実行、または [clearResult] 直後は `null`。
  Result<T>? get result => _result;

  /// 直近の実行結果が [Error] だったかどうか。
  bool get error => _result is Error;

  /// 直近の実行結果が [Ok] だったかどうか。
  bool get completed => _result is Ok;

  /// 保持している結果をクリアする(エラー表示の消去などに使う)。
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    // 実行中の多重実行(二重タップ等)を防止する。
    if (_running) {
      return;
    }

    _running = true;
    // 前回の結果を実行中の画面に見せ続けないよう、開始時点でリセットする。
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// 引数を取らないアクションを実行する [Command]。
final class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  /// アクションを実行する。
  Future<void> execute() async => _execute(_action);
}

/// 引数を1つ取るアクションを実行する [Command]。
final class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  /// [argument] を渡してアクションを実行する。
  Future<void> execute(A argument) async => _execute(() => _action(argument));
}
