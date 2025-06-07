import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/vo/budget_spent.dart';

void main() {
  group('BudgetSpentVo', () {
    test('正の値で作成できること', () {
      const spent = BudgetSpentVo(100);
      expect(spent.value, 100);
    });

    test('0で作成できること', () {
      const spent = BudgetSpentVo(0);
      expect(spent.value, 0);
    });

    test('負の値で作成するとアサーションエラーが発生すること', () {
      expect(() => BudgetSpentVo(-1), throwsAssertionError);
    });

    test('sumメソッドで合計値を計算できること', () {
      const spents = [
        BudgetSpentVo(100),
        BudgetSpentVo(200),
        BudgetSpentVo(300),
      ];
      final sum = BudgetSpentVo.sum(spents);
      expect(sum.value, 600);
    });

    test('0の場合、isNotUsedがtrueであること', () {
      const spent = BudgetSpentVo(0);
      expect(spent.isUsed, false);
      expect(spent.isNotUsed, true);
    });

    test('正の値の場合、isUsedがtrueであること', () {
      const spent = BudgetSpentVo(100);
      expect(spent.isUsed, true);
      expect(spent.isNotUsed, false);
    });

    test('toDoubleで適切にdoubleに変換されること', () {
      const spent = BudgetSpentVo(100);
      expect(spent.toDouble, 100.0);
    });
  });
}