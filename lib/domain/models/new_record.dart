import 'package:freezed_annotation/freezed_annotation.dart';

import 'amount.dart';
import 'balance_effect.dart';
import 'category_id.dart';
import 'property_id.dart';
import 'record_date.dart';
import 'record_note.dart';

part 'new_record.freezed.dart';

/// 未保存の収入/支出/振替の記録を表すsealed union。
///
/// [Record]と持つ情報はほぼ重複するが、IDを持たない([Record]は
/// [RecordId]を必須で持つ)。「保存済みかどうか」を型で区別することで、
/// 未保存のレコードにIDを要求してしまう(あるいは保存済みのレコードで
/// IDの有無を実行時に確認する)経路をコンパイル時に排除する。
@freezed
sealed class NewRecord with _$NewRecord {
  const NewRecord._();

  /// 収入の記録。
  const factory NewRecord.income({
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required CategoryId categoryId,
    required PropertyId propertyId,
  }) = NewIncomeRecord;

  /// 支出の記録。
  const factory NewRecord.expense({
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required CategoryId categoryId,
    required PropertyId propertyId,
  }) = NewExpenseRecord;

  /// 振替の記録。
  ///
  /// [fromPropertyId]と[toPropertyId]が同一のときはビジネスルール違反であり、
  /// 呼び出し側の実装ミス(ユーザーの入力ミスではない)であるため、AssertionErrorで
  /// fail fastさせる。
  @Assert('fromPropertyId != toPropertyId', '振替元と振替先は異なる資産が必要')
  const factory NewRecord.transfer({
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required PropertyId fromPropertyId,
    required PropertyId toPropertyId,
  }) = NewTransferRecord;

  /// このレコードが資産残高に与える増減。
  ///
  /// 資産の残高はレコードの集合から導出される派生値である、というルールの
  /// 定義箇所。収入/支出は対象資産1件の増減、振替は振替元の減少と振替先の
  /// 増加の2件からなる。
  List<BalanceEffect> get balanceEffects => switch (this) {
    NewIncomeRecord(:final amount, :final propertyId) => [
      (propertyId: propertyId, delta: amount.value),
    ],
    NewExpenseRecord(:final amount, :final propertyId) => [
      (propertyId: propertyId, delta: -amount.value),
    ],
    NewTransferRecord(
      :final amount,
      :final fromPropertyId,
      :final toPropertyId,
    ) =>
      [
        (propertyId: fromPropertyId, delta: -amount.value),
        (propertyId: toPropertyId, delta: amount.value),
      ],
  };
}
