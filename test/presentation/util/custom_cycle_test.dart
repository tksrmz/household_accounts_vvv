import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/presentation/util/custom_cycle.dart';

void main() {
  group('コンストラクタの誓約', () {
    test('beginがendより前であること', () {
      // CustomCycle(2026, 7) の begin(6/16) は end(7/16) より前であるため、
      // assertは通過し例外は発生しない
      expect(() => CustomCycle(2026, 7), returnsNormally);
    });
  });

  group('境界（AC-002相当）', () {
    // 「7月度」= 6/16 00:00:00（含む）〜 7/16 00:00:00（含まない）
    final julyCycle = CustomCycle(2026, 7);

    test('7月度のbeginが6/16 00:00:00であること', () {
      expect(julyCycle.begin, DateTime(2026, 6, 16));
    });

    test('7月度のendが7/16 00:00:00であること', () {
      expect(julyCycle.end, DateTime(2026, 7, 16));
    });

    test('6/15 23:59:59はbegin未満で期間外であること', () {
      final target = DateTime(2026, 6, 15, 23, 59, 59);
      expect(target.isBefore(julyCycle.begin), isTrue);
    });

    test('6/16 00:00:00はbegin以上end未満で期間内であること', () {
      final target = DateTime(2026, 6, 16);
      expect(
        !target.isBefore(julyCycle.begin) && target.isBefore(julyCycle.end),
        isTrue,
      );
    });

    test('7/15 23:59:59はbegin以上end未満で期間内であること', () {
      final target = DateTime(2026, 7, 15, 23, 59, 59);
      expect(
        !target.isBefore(julyCycle.begin) && target.isBefore(julyCycle.end),
        isTrue,
      );
    });

    test('7/16 00:00:00はend以上で期間外であること', () {
      final target = DateTime(2026, 7, 16);
      expect(!target.isBefore(julyCycle.end), isTrue);
    });
  });

  group('所属判定（AC-006/007相当）', () {
    test('基準日7/5のとき、7月度に属すること', () {
      final cycle = CustomCycle.containing(DateTime(2026, 7, 5));
      expect(cycle.year, 2026);
      expect(cycle.month, 7);
    });

    test('基準日7/15のとき、7月度に属すること', () {
      final cycle = CustomCycle.containing(DateTime(2026, 7, 15));
      expect(cycle.year, 2026);
      expect(cycle.month, 7);
    });

    test('基準日7/16のとき、8月度に属すること', () {
      final cycle = CustomCycle.containing(DateTime(2026, 7, 16));
      expect(cycle.year, 2026);
      expect(cycle.month, 8);
    });

    test('基準日7/31のとき、8月度に属すること', () {
      final cycle = CustomCycle.containing(DateTime(2026, 7, 31));
      expect(cycle.year, 2026);
      expect(cycle.month, 8);
    });

    test('基準日7/1のとき、7月度に属すること', () {
      final cycle = CustomCycle.containing(DateTime(2026, 7, 1));
      expect(cycle.year, 2026);
      expect(cycle.month, 7);
    });
  });

  group('年またぎ', () {
    test('基準日1/10のとき、1月度（begin=前年12/16）に属すること', () {
      final cycle = CustomCycle.containing(DateTime(2026, 1, 10));
      expect(cycle.year, 2026);
      expect(cycle.month, 1);
      expect(cycle.begin, DateTime(2025, 12, 16));
      expect(cycle.end, DateTime(2026, 1, 16));
    });

    test('12月度の次が翌年1月度であること', () {
      final december = CustomCycle(2025, 12);
      final next = december.next();
      expect(next.year, 2026);
      expect(next.month, 1);
    });

    test('1月度の前が前年12月度であること', () {
      final january = CustomCycle(2026, 1);
      final previous = january.previous();
      expect(previous.year, 2025);
      expect(previous.month, 12);
    });
  });

  group('うるう年（AC-011相当）', () {
    test('2024年3月度（うるう年）のbegin/endが2/16〜3/16であること', () {
      final cycle = CustomCycle(2024, 3);
      expect(cycle.begin, DateTime(2024, 2, 16));
      expect(cycle.end, DateTime(2024, 3, 16));
    });

    test('2024年2月度（うるう年）のbegin/endが1/16〜2/16であること', () {
      final cycle = CustomCycle(2024, 2);
      expect(cycle.begin, DateTime(2024, 1, 16));
      expect(cycle.end, DateTime(2024, 2, 16));
    });

    test('うるう年2024年、2月度のendと3月度のbeginが一致し欠落・重複がないこと', () {
      final february = CustomCycle(2024, 2);
      final march = CustomCycle(2024, 3);
      expect(february.end, march.begin);
    });

    test('非うるう年2025年でも、2月度のendと3月度のbeginが一致し欠落・重複がないこと', () {
      final february = CustomCycle(2025, 2);
      final march = CustomCycle(2025, 3);
      expect(february.end, march.begin);
      expect(february.begin, DateTime(2025, 1, 16));
      expect(february.end, DateTime(2025, 2, 16));
      expect(march.end, DateTime(2025, 3, 16));
    });
  });

  group('前後移動（AC-009相当）', () {
    test('7月度の前が6月度（begin=5/16）であること', () {
      final july = CustomCycle(2026, 7);
      final previous = july.previous();
      expect(previous.year, 2026);
      expect(previous.month, 6);
      expect(previous.begin, DateTime(2026, 5, 16));
    });

    test('7月度の次が8月度であること', () {
      final july = CustomCycle(2026, 7);
      final next = july.next();
      expect(next.year, 2026);
      expect(next.month, 8);
    });
  });

  group('未来判定（AC-010相当）', () {
    test('基準日7/5のとき、7月度は基準日が属する月度でありこれ以上進めない判定がtrueであること', () {
      final baseDate = DateTime(2026, 7, 5);
      final july = CustomCycle.containing(baseDate);
      expect(july.isCurrent(baseDate), isTrue);
    });

    test('基準日7/5のとき、6月度はこれ以上進めない判定がfalseであること', () {
      final baseDate = DateTime(2026, 7, 5);
      final june = CustomCycle(2026, 6);
      expect(june.isCurrent(baseDate), isFalse);
    });
  });

  group('連続性', () {
    test('隣接する複数月度で、前の月度のendが次の月度のbeginと一致すること', () {
      var cycle = CustomCycle(2026, 1);
      for (var i = 0; i < 12; i++) {
        final next = cycle.next();
        expect(cycle.end, next.begin);
        cycle = next;
      }
    });
  });

  group('正規化された年月の公開', () {
    test('next()を12月度に対して呼んでも、内部でmonth=13を公開せず翌年1月度として正規化されること', () {
      final result = CustomCycle(2026, 12).next();
      expect(result.year, 2027);
      expect(result.month, 1);
    });

    test('previous()を1月度に対して呼んでも、内部でmonth=0を公開せず前年12月度として正規化されること', () {
      final result = CustomCycle(2026, 1).previous();
      expect(result.year, 2025);
      expect(result.month, 12);
    });
  });
}
