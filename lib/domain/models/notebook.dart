import 'package:freezed_annotation/freezed_annotation.dart';

import 'pair_id.dart';
import 'user_id.dart';

part 'notebook.freezed.dart';

/// 個人ノート/共有ノートを表すsealed union。
///
/// 個人ノートと共有ノートの違いは、Firestore上のルートパス
/// (`personalNotes/{uid}` か `sharedNotes/{pairId}` か)だけである。
/// この型はRepositoryがそのパスを組み立てる際にどちらを選ぶかを表す。
@freezed
sealed class Notebook with _$Notebook {
  /// 個人ノート。
  const factory Notebook.personal(UserId uid) = PersonalNotebook;

  /// 共有ノート。
  const factory Notebook.shared(PairId pairId) = SharedNotebook;
}
