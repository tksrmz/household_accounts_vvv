import 'package:household_accounts/util/extension/date_time.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeが期待通りの動きをすること', () {
    test('DateTime(2024, 13)とDateTime(2025, 1)が等しいこと', () {
      // DateTime(other.year, other.month + 1)がotherの1ヶ月後になることの確認
      expect(DateTime(2024, 13), DateTime(2025, 1));
    });
  });

  group('MonthCalculation', () {
    test('nextMonthで1ヶ月後のDateTimeが取得できること', () {
      expect(DateTime(2025, 1).nextMonth(), DateTime(2025, 2));
    });

    test('12月の1ヶ月後が翌年1月であること', () {
      expect(DateTime(2025, 12).nextMonth(), DateTime(2026, 1));
    });
  });

  group('DateModifier', () {
    test('toFirstDayOfMonthで月初日のDateTimeが取得できること', () {
      expect(DateTime(2025, 1, 15).toFirstDayOfMonth(), DateTime(2025, 1));
    });

    test('月初日のDateTimeがそのままの場合、そのままの値が取得できること', () {
      expect(DateTime(2025, 1, 1).toFirstDayOfMonth(), DateTime(2025, 1));
    });
  });
}
