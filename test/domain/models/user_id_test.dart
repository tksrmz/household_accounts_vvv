import 'package:household_accounts/domain/models/user_id.dart';
import 'package:test/test.dart';

// なぜExceptionではなくArgumentErrorを期待するか:
// 空のユーザーIDはユーザー入力の誤りではなく不具合の兆候であり、
// 捕捉されずfail fastすることが仕様である。
void main() {
  group('コンストラクタ', () {
    test('空でない文字列のとき、インスタンスを生成できること', () {
      expect(UserId('test-uid').value, 'test-uid');
    });

    test('空文字のとき、ArgumentErrorが送出されること', () {
      expect(() => UserId(''), throwsArgumentError);
    });
  });
}
