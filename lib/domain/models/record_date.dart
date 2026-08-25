import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_date.freezed.dart';

/// レコード(収入/支出/振替)の日付の値オブジェクト。
///
/// この型自体は値を検証しない。未来日付の禁止は記録入力の入力境界
/// (DatePickerの選択可能範囲の制限とドラフトの検証)で行う。読み取り経路
/// (一覧・集計)には、旧UIが許していた入力(+365日先まで入力可能だった)による
/// 過去に保存済みの未来日付レコードや、テストフィクスチャの値が存在しうるため、
/// この型のコンストラクタでは検証しない(検証をここに置くと、そうした既存データの
/// 読み込みそのものが例外で失敗してしまう)。
@freezed
abstract class RecordDate with _$RecordDate {
  const factory RecordDate(DateTime value) = _RecordDate;
}
