/// 「N月度」（前月16日〜当月15日サイクル）を表すイミュータブルな値クラス。
///
/// なぜ半開区間で表現するか:
/// FirestoreクエリのbeginInclusive/endExclusiveと自然に対応させ、
/// 境界レコード（6/15・7/16等）の重複・欠落を防ぐため。
///
/// なぜ「今日」を内部で取得しないか:
/// AC-006/007/010（今日が属する月度の判定・未来判定）をテストで
/// 固定日付を注入して検証できるようにするため（design.md セクション3参照）。
class CustomCycle {
  /// [year]・[month] は表示に使う月度の年月（例: 2026年7月度なら year=2026, month=7）。
  ///
  /// 誓約: begin（前月16日 00:00:00）はend（当月16日 00:00:00）より前でなければならない。
  /// month方向への繰り上げ・繰り下げは `DateTime` の自動正規化に委ねるため、
  /// 通常の年月値であればこの誓約は常に成立する。
  CustomCycle(int year, int month)
      : begin = DateTime(year, month - 1, 16),
        end = DateTime(year, month, 16) {
    assert(begin.isBefore(end), 'beginはendより前である必要があります');
  }

  /// 前月16日 00:00:00（含む）
  final DateTime begin;

  /// 当月16日 00:00:00（含まない）
  final DateTime end;

  /// 画面表示用に正規化された月度の年（内部でmonth=0や13のような値を公開しない）。
  ///
  /// endが「当月16日 00:00:00」であるため、endの年月がそのままこの月度の年月となる。
  int get year => end.year;

  /// 画面表示用に正規化された月度の月（1〜12）。
  int get month => end.month;

  /// 基準日[baseDate]が属する月度を返す。
  ///
  /// 「今日が属する月度」の定義（requirements.md 用語定義）:
  /// 日が1〜15なら当月度、16〜末日なら翌月度。
  factory CustomCycle.containing(DateTime baseDate) {
    final belongsToNextMonth = baseDate.day >= 16;
    final monthOffset = belongsToNextMonth ? 1 : 0;
    return CustomCycle(baseDate.year, baseDate.month + monthOffset);
  }

  /// 1つ前の月度を返す。
  CustomCycle previous() => CustomCycle(year, month - 1);

  /// 1つ次の月度を返す。
  CustomCycle next() => CustomCycle(year, month + 1);

  /// 基準日[baseDate]が属する月度と同一か（=これ以上先に進めないか）を判定する。
  bool isCurrent(DateTime baseDate) {
    final currentCycle = CustomCycle.containing(baseDate);
    return year == currentCycle.year && month == currentCycle.month;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCycle && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}
