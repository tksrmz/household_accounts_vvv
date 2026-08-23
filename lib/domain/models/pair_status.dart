import 'package:freezed_annotation/freezed_annotation.dart';

import 'pair_id.dart';

part 'pair_status.freezed.dart';

/// ペアリング状態を表すsealed union
@freezed
sealed class PairStatus with _$PairStatus {
  /// ペアリング済み
  const factory PairStatus.paired(PairId pairId) = Paired;

  /// 未ペアリング
  const factory PairStatus.notPaired() = NotPaired;
}
