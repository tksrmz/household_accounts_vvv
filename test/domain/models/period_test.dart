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

  group('day', () {
    test('月の途中の日のとき、その日0時から翌日0時までの半開区間になること', () {
      final period = Period.day(2026, 8, 15);

      expect(period.start, DateTime(2026, 8, 15));
      expect(period.end, DateTime(2026, 8, 16));
    });

    test('月末日のとき、endが翌月1日になること', () {
      final period = Period.day(2026, 8, 31);

      expect(period.start, DateTime(2026, 8, 31));
      expect(period.end, DateTime(2026, 9, 1));
    });

    test('12月31日のとき、endが翌年1月1日になること', () {
      final period = Period.day(2026, 12, 31);

      expect(period.start, DateTime(2026, 12, 31));
      expect(period.end, DateTime(2027, 1, 1));
    });

    test('うるう年の2月29日のとき、インスタンスを生成できること', () {
      final period = Period.day(2024, 2, 29);

      expect(period.start, DateTime(2024, 2, 29));
      expect(period.end, DateTime(2024, 3, 1));
    });

    test('平年の2月29日のとき、ArgumentErrorが送出されること', () {
      expect(() => Period.day(2026, 2, 29), throwsArgumentError);
    });

    test('30日までの月の31日のとき、ArgumentErrorが送出されること', () {
      expect(() => Period.day(2026, 4, 31), throwsArgumentError);
    });

    test('日が0のとき、ArgumentErrorが送出されること', () {
      expect(() => Period.day(2026, 8, 0), throwsArgumentError);
    });

    test('月が0のとき、ArgumentErrorが送出されること', () {
      expect(() => Period.day(2026, 0, 1), throwsArgumentError);
    });

    test('月が13のとき、ArgumentErrorが送出されること', () {
      expect(() => Period.day(2026, 13, 1), throwsArgumentError);
    });
  });
}
