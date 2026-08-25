import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/utils/combine_latest.dart';

void main() {
  group('combineLatest3', () {
    test('3本すべてがemitするまで、出力が何もemitしないこと', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      final events = <String>[];

      combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => '$x-$y-$z',
      ).listen(events.add);

      a.add(1);
      await pumpEventQueue();
      b.add(2);
      await pumpEventQueue();

      expect(events, isEmpty);

      await a.close();
      await b.close();
      await c.close();
    });

    test('3本すべてが揃った時点で、最新値の組み合わせが出力されること', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      final events = <String>[];

      combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => '$x-$y-$z',
      ).listen(events.add);

      a.add(1);
      b.add(2);
      c.add(3);
      await pumpEventQueue();

      expect(events, ['1-2-3']);

      await a.close();
      await b.close();
      await c.close();
    });

    test('揃った後にいずれかがemitしたとき、最新値の組み合わせで再出力されること', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      final events = <String>[];

      combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => '$x-$y-$z',
      ).listen(events.add);

      a.add(1);
      b.add(2);
      c.add(3);
      await pumpEventQueue();

      b.add(20);
      await pumpEventQueue();
      a.add(10);
      await pumpEventQueue();

      expect(events, ['1-2-3', '1-20-3', '10-20-3']);

      await a.close();
      await b.close();
      await c.close();
    });

    test('ソースがエラーをemitしたとき、出力へ転送され購読が維持されること', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      final events = <String>[];
      final errors = <Object>[];
      final exception = Exception('ソースのエラー');

      combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => '$x-$y-$z',
      ).listen(events.add, onError: errors.add);

      a.add(1);
      b.add(2);
      c.add(3);
      await pumpEventQueue();

      a.addError(exception);
      await pumpEventQueue();

      // エラーの後も購読が維持され、後続のemitが届くこと
      a.add(10);
      await pumpEventQueue();

      expect(errors, [exception]);
      expect(events, ['1-2-3', '10-2-3']);

      await a.close();
      await b.close();
      await c.close();
    });

    test('ソースがエラーをemitした後、そのソースが回復するまで他のソースのemitでは出力されないこと', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      final events = <String>[];
      final errors = <Object>[];

      combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => '$x-$y-$z',
      ).listen(events.add, onError: errors.add);

      a.add(1);
      b.add(2);
      c.add(3);
      await pumpEventQueue();

      a.addError(Exception('ソースのエラー'));
      await pumpEventQueue();

      // エラー中のaの古い値(1)との組で出力してはならない
      b.add(20);
      await pumpEventQueue();
      expect(events, ['1-2-3']);

      // aが回復した時点で、他ソースの最新値との組で出力が再開する
      a.add(10);
      await pumpEventQueue();
      expect(events, ['1-2-3', '10-20-3']);

      await a.close();
      await b.close();
      await c.close();
    });

    test('combine内でthrowしたとき、出力のエラーになり購読が維持されること', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      final events = <String>[];
      final errors = <Object>[];
      final exception = Exception('combineでの失敗');

      combineLatest3(a.stream, b.stream, c.stream, (x, y, z) {
        if (x == 99) {
          throw exception;
        }
        return '$x-$y-$z';
      }).listen(events.add, onError: errors.add);

      a.add(1);
      b.add(2);
      c.add(3);
      await pumpEventQueue();

      a.add(99);
      await pumpEventQueue();

      a.add(5);
      await pumpEventQueue();

      expect(errors, [exception]);
      expect(events, ['1-2-3', '5-2-3']);

      await a.close();
      await b.close();
      await c.close();
    });

    test('3本すべてがdoneになったとき、出力がcloseすること', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      var isDone = false;

      combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => x + y + z,
      ).listen((_) {}, onDone: () => isDone = true);

      a.add(1);
      b.add(2);
      c.add(3);
      await pumpEventQueue();

      await a.close();
      await pumpEventQueue();
      expect(isDone, isFalse);

      await b.close();
      await pumpEventQueue();
      expect(isDone, isFalse);

      await c.close();
      await pumpEventQueue();
      expect(isDone, isTrue);
    });

    test('出力の購読をキャンセルしたとき、3本のソースすべての購読が解除されること', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final c = StreamController<int>();
      var aCancelled = false;
      var bCancelled = false;
      var cCancelled = false;
      a.onCancel = () => aCancelled = true;
      b.onCancel = () => bCancelled = true;
      c.onCancel = () => cCancelled = true;

      final subscription = combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => x + y + z,
      ).listen((_) {});

      a.add(1);
      b.add(2);
      c.add(3);
      await pumpEventQueue();

      await subscription.cancel();

      expect(aCancelled, isTrue);
      expect(bCancelled, isTrue);
      expect(cCancelled, isTrue);
    });
  });
}
