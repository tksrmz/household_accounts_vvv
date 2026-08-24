import 'package:household_accounts/domain/models/period.dart';
import 'package:test/test.dart';

void main() {
  group('コンストラクタ', () {
    test('startがendより前のとき、インスタンスを生成できること', () {
      final start = DateTime(2026, 8, 1);
      final end = DateTime(2026, 9, 1);

      final period = Period(start: start, end: end);

      expect(period.start, start);
      expect(period.end, end);
    });

    test('startとendが同じとき、ArgumentErrorが送出されること', () {
      final same = DateTime(2026, 8, 1);

      expect(() => Period(start: same, end: same), throwsArgumentError);
    });

    test('startがendより後のとき、ArgumentErrorが送出されること', () {
      expect(
        () => Period(start: DateTime(2026, 9, 1), end: DateTime(2026, 8, 1)),
        throwsArgumentError,
      );
    });
  });

  group('calendarMonth', () {
    test('通常の月のとき、月初0時から翌月初0時までの半開区間になること', () {
      final period = Period.calendarMonth(2026, 8);

      expect(period.start, DateTime(2026, 8, 1));
      expect(period.end, DateTime(2026, 9, 1));
    });

    test('12月のとき、endが翌年1月になること', () {
      final period = Period.calendarMonth(2026, 12);

      expect(period.start, DateTime(2026, 12, 1));
      expect(period.end, DateTime(2027, 1, 1));
    });

    test('2月のとき、endが3月になること', () {
      final period = Period.calendarMonth(2026, 2);

      expect(period.start, DateTime(2026, 2, 1));
      expect(period.end, DateTime(2026, 3, 1));
    });

    test('月が0のとき、ArgumentErrorが送出されること', () {
      expect(() => Period.calendarMonth(2026, 0), throwsArgumentError);
    });

    test('月が13のとき、ArgumentErrorが送出されること', () {
      expect(() => Period.calendarMonth(2026, 13), throwsArgumentError);
    });
  });
}
