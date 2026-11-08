import 'package:household_accounts/domain/models/fiscal_month.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:test/test.dart';

void main() {
  group('コンストラクタ', () {
    test('月が1〜12のとき、年月を保持すること', () {
      final fiscalMonth = FiscalMonth(2026, 7);

      expect(fiscalMonth.year, 2026);
      expect(fiscalMonth.month, 7);
    });

    test('月が0のとき、ArgumentErrorが送出されること', () {
      expect(() => FiscalMonth(2026, 0), throwsArgumentError);
    });

    test('月が13のとき、ArgumentErrorが送出されること', () {
      expect(() => FiscalMonth(2026, 13), throwsArgumentError);
    });
  });

  group('期間の境界', () {
    // 「7月度」= 6/16 0時(含む)〜7/16 0時(含まない)
    final july = FiscalMonth(2026, 7).period;

    test('7月度のとき、期間が6/16 0時から7/16 0時までであること', () {
      expect(
        july,
        Period(start: DateTime(2026, 6, 16), end: DateTime(2026, 7, 16)),
      );
    });

    test('6/15 23:59:59のとき、7月度の期間外であること', () {
      expect(_contains(july, DateTime(2026, 6, 15, 23, 59, 59)), isFalse);
    });

    test('6/16 0時のとき、7月度の期間内であること', () {
      expect(_contains(july, DateTime(2026, 6, 16)), isTrue);
    });

    test('7/15 23:59:59のとき、7月度の期間内であること', () {
      expect(_contains(july, DateTime(2026, 7, 15, 23, 59, 59)), isTrue);
    });

    test('7/16 0時のとき、7月度の期間外であること', () {
      expect(_contains(july, DateTime(2026, 7, 16)), isFalse);
    });
  });

  group('所属する月度', () {
    test('7/1のとき、7月度に属すること', () {
      expect(
        FiscalMonth.containing(DateTime(2026, 7, 1)),
        FiscalMonth(2026, 7),
      );
    });

    test('7/5のとき、7月度に属すること', () {
      expect(
        FiscalMonth.containing(DateTime(2026, 7, 5)),
        FiscalMonth(2026, 7),
      );
    });

    test('7/15の23:59:59のとき、7月度に属すること', () {
      expect(
        FiscalMonth.containing(DateTime(2026, 7, 15, 23, 59, 59)),
        FiscalMonth(2026, 7),
      );
    });

    test('7/16のとき、8月度に属すること', () {
      expect(
        FiscalMonth.containing(DateTime(2026, 7, 16)),
        FiscalMonth(2026, 8),
      );
    });

    test('7/31のとき、8月度に属すること', () {
      expect(
        FiscalMonth.containing(DateTime(2026, 7, 31)),
        FiscalMonth(2026, 8),
      );
    });
  });

  group('年またぎ', () {
    test('1/10のとき、1月度に属し期間の開始が前年12/16であること', () {
      final fiscalMonth = FiscalMonth.containing(DateTime(2026, 1, 10));

      expect(fiscalMonth, FiscalMonth(2026, 1));
      expect(
        fiscalMonth.period,
        Period(start: DateTime(2025, 12, 16), end: DateTime(2026, 1, 16)),
      );
    });

    test('12/16のとき、翌年の1月度に属すること', () {
      expect(
        FiscalMonth.containing(DateTime(2026, 12, 16)),
        FiscalMonth(2027, 1),
      );
    });
  });

  group('うるう年', () {
    test('2024年3月度のとき、期間が2/16から3/16までであること', () {
      expect(
        FiscalMonth(2024, 3).period,
        Period(start: DateTime(2024, 2, 16), end: DateTime(2024, 3, 16)),
      );
    });

    test('2024年2月度のとき、期間が1/16から2/16までであること', () {
      expect(
        FiscalMonth(2024, 2).period,
        Period(start: DateTime(2024, 1, 16), end: DateTime(2024, 2, 16)),
      );
    });
  });

  group('連続性', () {
    test('隣接する月度のとき、前の月度の終了と次の月度の開始が一致し欠落も重複もないこと', () {
      // うるう年(2024年)・平年(2025年)の2月と年またぎを含む25か月を確かめる
      for (var offset = 0; offset < 25; offset++) {
        final current = DateTime(2024, 1 + offset);
        final following = DateTime(2024, 2 + offset);

        expect(
          FiscalMonth(current.year, current.month).period.end,
          FiscalMonth(following.year, following.month).period.start,
        );
      }
    });
  });
}

/// [period]が[dateTime]を含むかどうか(start以上end未満)。
bool _contains(Period period, DateTime dateTime) =>
    !dateTime.isBefore(period.start) && dateTime.isBefore(period.end);
