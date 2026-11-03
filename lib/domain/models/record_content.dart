import 'package:freezed_annotation/freezed_annotation.dart';

import 'amount.dart';
import 'balance_effect.dart';
import 'category_id.dart';
import 'property_id.dart';
import 'record_date.dart';
import 'record_note.dart';

part 'record_content.freezed.dart';

/// 収入/支出/振替の記録の内容を表すsealed union。
///
/// IDの有無・保存状態とは無関係な概念であり、[Record]とは保存済みの
/// 同一性(ID)を持つかどうかで役割が分かれる([Record]は
/// [RecordId]を必須で持つ。[Record.content]で保存済みレコードから
/// このsealed unionを取り出せる)。
@freezed
sealed class RecordContent with _$RecordContent {
  const RecordContent._();

  /// 収入の記録内容。
  const factory RecordContent.income({
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required CategoryId categoryId,
    required PropertyId propertyId,
  }) = IncomeRecordContent;

  /// 支出の記録内容。
  const factory RecordContent.expense({
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required CategoryId categoryId,
    required PropertyId propertyId,
  }) = ExpenseRecordContent;

  /// 振替の記録内容。
  ///
  /// [fromPropertyId]と[toPropertyId]が同一のときはビジネスルール違反であり、
  /// 呼び出し側の実装ミス(ユーザーの入力ミスではない)であるため、AssertionErrorで
  /// fail fastさせる。
  @Assert('fromPropertyId != toPropertyId', '振替元と振替先は異なる資産が必要')
  const factory RecordContent.transfer({
    required RecordDate date,
    required Amount amount,
    required RecordNote note,
    required PropertyId fromPropertyId,
    required PropertyId toPropertyId,
  }) = TransferRecordContent;

  /// この内容が資産残高に与える増減。
  ///
  /// 資産の残高はレコードの集合から導出される派生値である、というルールの
  /// 定義箇所。収入/支出は対象資産1件の増減、振替は振替元の減少と振替先の
  /// 増加の2件からなる。
  List<BalanceEffect> get balanceEffects => switch (this) {
    IncomeRecordContent(:final amount, :final propertyId) => [
      (propertyId: propertyId, delta: amount.value),
    ],
    ExpenseRecordContent(:final amount, :final propertyId) => [
      (propertyId: propertyId, delta: -amount.value),
    ],
    TransferRecordContent(
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
