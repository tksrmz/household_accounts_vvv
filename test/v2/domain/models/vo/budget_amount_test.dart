import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/budget_amount.dart';

void main() {
  group('BudgetAmountVo', () {
    group('コンストラクタ', () {
      test('正の値で作成できること', () {
        const amount = BudgetAmountVo(100);
        expect(amount.value, 100);
      });

      test('0で作成できること', () {
        const amount = BudgetAmountVo(0);
        expect(amount.value, 0);
      });

      test('負の値で作成するとアサーションエラーが発生すること', () {
        expect(() => BudgetAmountVo(-1), throwsAssertionError);
      });
    });

    group('sum', () {
      test('合計値を計算できること', () {
        const amounts = [
          BudgetAmountVo(100),
          BudgetAmountVo(200),
          BudgetAmountVo(300),
        ];
        final sum = BudgetAmountVo.sum(amounts);
        expect(sum.value, 600);
      });

      test('空のリストの合計は0になること', () {
        final sum = BudgetAmountVo.sum([]);
        expect(sum.value, 0);
      });
    });
  });
}
