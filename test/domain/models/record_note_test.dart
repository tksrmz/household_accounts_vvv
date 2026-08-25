import 'package:household_accounts/domain/models/record_note.dart';
import 'package:test/test.dart';

// なぜAssertionErrorではなくFormatExceptionを期待するか:
// 誓約はassertではなくthrowで表現しており、リリースビルドでも同じように
// 効くことが仕様である。
void main() {
  group('コンストラクタ', () {
    for (final value in ['', 'a', 'b' * 100]) {
      test('${value.length}文字の文字列のとき、インスタンスを生成できること', () {
        expect(RecordNote(value).value, value);
      });
    }

    test('101文字の文字列のとき、FormatExceptionが送出されること', () {
      expect(() => RecordNote('a' * 101), throwsFormatException);
    });
  });
}
