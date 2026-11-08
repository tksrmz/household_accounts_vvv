import 'package:freezed_annotation/freezed_annotation.dart';

import 'period.dart';

part 'fiscal_month.freezed.dart';

/// 月度が始まる日。「N月度」は前月のこの日の0時に始まり、当月のこの日の0時に
/// 終わる。
///
/// 締め日を利用者が設定する機能は持たないため、引数にせずここ1か所で定める。
const _startDay = 16;

/// 16日始まりの「月度」の値オブジェクト。
///
/// 「N月度」は前月16日0時から当月16日0時までの半開区間を表す(例えば
/// 2026年7月度は6/16〜7/15)。年月の組として持ち、レコードを絞り込む区間は
/// [period]で求める。
@freezed
class FiscalMonth with _$FiscalMonth {
  /// [month]が1〜12の範囲外のとき[ArgumentError]を送出する。
  ///
  /// 月度の年月はアプリ内で計算して渡す値であり、範囲外になるのは呼び出し側の
  /// 実装ミスであるため、捕捉されず伝播するErrorを送出してfail fastさせる。
  /// [DateTime]のコンストラクタは月が範囲外でも自動的に正規化してしまう
  /// (例えば13を渡すと翌年1月として解釈される)ため、その正規化に頼らず
  /// 明示的に検証する([Period.calendarMonth]と同じ扱い)。
  FiscalMonth(this.year, this.month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', '月は1から12の範囲である必要があります');
    }
  }

  /// [date]が属する月度を返す。
  ///
  /// 日が1〜15なら当月度、16〜末日なら翌月度に属する(12月16日以降は
  /// 翌年1月度)。
  factory FiscalMonth.containing(DateTime date) {
    if (date.day < _startDay) {
      return FiscalMonth(date.year, date.month);
    }
    // DateTimeの正規化に年またぎ(12月の翌月)の計算を任せる
    final next = DateTime(date.year, date.month + 1);
    return FiscalMonth(next.year, next.month);
  }

  /// 表示に使う月度の年(「2026年7月度」の2026)。
  final int year;

  /// 表示に使う月度の月(1〜12。「2026年7月度」の7)。
  final int month;

  /// この月度の期間(前月16日0時〜当月16日0時の半開区間)。
  ///
  /// 前月の算出(1月度の前年12月など)は[DateTime]の正規化に任せる。
  Period get period => Period(
    start: DateTime(year, month - 1, _startDay),
    end: DateTime(year, month, _startDay),
  );
}
