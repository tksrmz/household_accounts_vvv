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
}
