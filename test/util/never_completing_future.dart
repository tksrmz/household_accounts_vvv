import 'dart:async';

Future<T> neverCompletingFuture<T>() {
  final completer = Completer<T>();
  return completer.future;
}
