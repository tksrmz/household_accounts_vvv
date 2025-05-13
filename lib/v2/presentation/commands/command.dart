import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class AsyncCommand<T> extends _AsyncCommandBase {
  AsyncCommand(this._command);

  final Future<void> Function(T) _command;

  Future<void> call(T t) async {
    return _execute(() => _command(t));
  }
}

class _AsyncCommandBase with ChangeNotifier {
  /// コマンドを実行可能かどうか
  bool _canExecute = true;
  bool get canExecute => _canExecute;
  bool get isExecuting => !canExecute;

  /// 初期化のエラー状態
  Exception? _error;
  Exception? get error => _error;
  bool get hasError => _error != null;

  Future<void> _execute(Future<void> Function() command) async {
    if (!canExecute) {
      return;
    }

    _canExecute = false;
    notifyListeners();

    try {
      await command();
      _error = null;
    } on Exception catch (ex, st) {
      developer.log(
        'AsyncCommand execution was failed',
        name: 'AsyncCommand',
        level: Level.WARNING.value,
        error: ex,
        stackTrace: st,
      );
      _error = ex;
    } finally {
      _canExecute = true;
      notifyListeners();
    }
  }
}
