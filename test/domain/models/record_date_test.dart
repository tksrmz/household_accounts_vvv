import 'package:household_accounts/domain/models/record_date.dart';
import 'package:test/test.dart';

void main() {
  group('コンストラクタ', () {
    test('渡した値をそのまま保持すること', () {
      final date = DateTime(2026, 8, 24);

      expect(RecordDate(date).value, date);
    });

    // なぜ未来日付を拒否しないことを明示的にテストするか:
    // 未来日付の禁止は記録入力の入力境界(DatePicker制限とドラフト検証)の
    // 責務であり、この型自体は検証しない設計である。読み取り経路
    // (旧UIが許していた+365日先までの入力や、テストフィクスチャ)には
    // 未来日付がそのまま存在しうるため、生成できることを仕様として固定する。
    test('未来日付でも、インスタンスを生成できること', () {
      final farFuture = DateTime(9999, 12, 31);

      expect(RecordDate(farFuture).value, farFuture);
    });
  });
}
