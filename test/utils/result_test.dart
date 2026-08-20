import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/utils/result.dart';

void main() {
  test('Result.okを生成したとき、switchでOkにマッチして値を取り出せること', () {
    final Result<int> result = Result.ok(1);

    final extractedValue = switch (result) {
      Ok(:final value) => value,
      Error() => fail('Errorにマッチしてはならない'),
    };

    expect(extractedValue, 1);
  });

  test('Result.errorを生成したとき、switchでErrorにマッチして例外を取り出せること', () {
    final exception = Exception('失敗');
    final Result<int> result = Result.error(exception);

    final extractedError = switch (result) {
      Ok() => fail('Okにマッチしてはならない'),
      Error(:final error) => error,
    };

    expect(extractedError, exception);
  });

  group('guard', () {
    test('guardに成功する処理を渡したとき、Okで値が返ること', () async {
      final result = await Result.guard(() async => 1);

      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 1);
    });

    test('guardに渡した処理がExceptionを投げたとき、Errorに変換されること', () async {
      final exception = Exception('想定内の失敗');

      final result = await Result.guard<int>(() async => throw exception);

      expect(result, isA<Error<int>>());
      expect((result as Error<int>).error, exception);
    });

    test('guardに渡した処理がDartのErrorを投げたとき、捕捉されず伝播すること', () async {
      await expectLater(
        Result.guard<int>(() async => throw StateError('バグ')),
        throwsStateError,
      );
    });
  });
}
