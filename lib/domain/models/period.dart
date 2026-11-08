import 'package:freezed_annotation/freezed_annotation.dart';

part 'period.freezed.dart';

/// 集計期間の値オブジェクト。半開区間 `[start, end)`(start以上end未満)で表す。
///
/// ダッシュボードや予算等、期間を指定してレコードを集計する画面が共通して使う。
@freezed
class Period with _$Period {
  /// [start]が[end]以上のとき[ArgumentError]を送出する。
  ///
  /// assertはリリースビルドで無効化されるため、誓約は全ビルドで効くthrowで表現する。
  /// 不正な期間(start >= end)は呼び出し側の実装ミスであり、ユーザーの入力ミスでは
  /// ないため、捕捉されず伝播するErrorを送出してfail fastさせる。
  Period({required this.start, required this.end}) {
    if (!start.isBefore(end)) {
      throw ArgumentError.value(end, 'end', 'endはstartより後の日時である必要があります');
    }
  }

  /// 期間の開始(この時刻を含む)。
  final DateTime start;

  /// 期間の終了(この時刻を含まない)。
  final DateTime end;

  /// [year]年[month]月の暦月(1日0時〜翌月1日0時)の期間を生成する。
  ///
  /// [month]が1〜12の範囲外のとき[ArgumentError]を送出する。[DateTime]の
  /// コンストラクタは月が範囲外でも自動的に正規化してしまう(例えば13を渡すと
  /// 翌年1月として解釈される)ため、その正規化に頼らず明示的に検証する。
  ///
  /// 16日始まりの月度の期間は`FiscalMonth.period`で求める。
  factory Period.calendarMonth(int year, int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', '月は1から12の範囲である必要があります');
    }
    return Period(start: DateTime(year, month), end: DateTime(year, month + 1));
  }

  /// [year]年[month]月[day]日の1日(0時〜翌日0時)の期間を生成する。
  ///
  /// [month]が1〜12の範囲外のとき、および[day]がその月の実日数の範囲外のときは
  /// [ArgumentError]を送出する。[calendarMonth]と同じ理由で、[DateTime]の
  /// 自動正規化(例えば2月30日を3月2日として解釈する)に頼らず明示的に検証する。
  factory Period.day(int year, int month, int day) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', '月は1から12の範囲である必要があります');
    }
    // 翌月0日は当月末日を表す(DateTimeの正規化を日数の算出にだけ利用する)。
    final lastDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > lastDay) {
      throw ArgumentError.value(day, 'day', '日は1から$lastDayの範囲である必要があります');
    }
    return Period(
      start: DateTime(year, month, day),
      end: DateTime(year, month, day + 1),
    );
  }
}
