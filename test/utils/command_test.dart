import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/utils/command.dart';
import 'package:household_accounts/utils/result.dart';

void main() {
  group('Command0', () {
    test('実行前のとき、runningがfalseでresultがnullであること', () {
      final command = Command0<int>(() async => const Result.ok(1));

      expect(command.running, isFalse);
      expect(command.result, isNull);
    });

    test('実行中のとき、runningがtrueになりresultがnullへリセットされること', () async {
      // 1回目を完了させ、resultに値が残っている状態を作ってから
      // 2回目の実行を開始し、完了前の状態(リセットされていること)を検証する。
      final completers = [Completer<Result<int>>(), Completer<Result<int>>()];
      var callCount = 0;
      final command = Command0<int>(() => completers[callCount++].future);

      completers[0].complete(const Result.ok(1));
      await command.execute();
      expect(command.result, isNotNull);

      final future = command.execute();

      expect(command.running, isTrue);
      expect(command.result, isNull);

      completers[1].complete(const Result.ok(2));
      await future;
    });

    test('アクションが成功したとき、completedがtrueになりresultにOkが入ること', () async {
      final command = Command0<int>(() async => const Result.ok(1));

      await command.execute();

      expect(command.running, isFalse);
      expect(command.completed, isTrue);
      expect(command.error, isFalse);
      expect(command.result, isA<Ok<int>>());
      expect((command.result as Ok<int>).value, 1);
    });

    test('アクションがErrorを返したとき、errorがtrueになること', () async {
      final exception = Exception('失敗');
      final command = Command0<int>(() async => Result.error(exception));

      await command.execute();

      expect(command.error, isTrue);
      expect(command.completed, isFalse);
      expect(command.result, isA<Error<int>>());
      expect((command.result as Error<int>).error, exception);
    });

    test('実行中に再度executeしたとき、2回目の実行が無視されること', () async {
      var callCount = 0;
      final completer = Completer<Result<int>>();
      final command = Command0<int>(() {
        callCount++;
        return completer.future;
      });

      final first = command.execute();
      final second = command.execute();

      // 実行中に呼んだ2回目はアクションを起動しないため、呼び出し回数は1回のまま。
      expect(callCount, 1);

      completer.complete(const Result.ok(1));
      await first;
      await second;
    });

    test('clearResultを呼んだとき、resultがnullへ戻り通知されること', () async {
      final command = Command0<int>(() async => const Result.ok(1));
      await command.execute();
      expect(command.result, isNotNull);

      var notifyCount = 0;
      command.addListener(() => notifyCount++);

      command.clearResult();

      expect(command.result, isNull);
      expect(notifyCount, 1);
    });
  });

  group('Command1', () {
    test('Command1をexecuteしたとき、引数がアクションへ渡されること', () async {
      String? receivedArgument;
      final command = Command1<int, String>((argument) async {
        receivedArgument = argument;
        return const Result.ok(1);
      });

      await command.execute('引数の値');

      expect(receivedArgument, '引数の値');
    });
  });
}
