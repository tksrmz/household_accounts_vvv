import '../../../domain/models/property.dart';

/// 資産を購読するRepository。
abstract interface class PropertyRepository {
  /// 資産の一覧を購読する。
  ///
  /// 契約:
  /// - 初回スナップショット(オフラインキャッシュ由来を含む)が届くまで
  ///   何もemitしない(購読側はローディングとして扱える)
  /// - 以降は変更のたびにリスト全体を再emitする
  /// - 並びは名前の昇順(旧実装の並びを踏襲)
  /// - ドキュメントがドメインの制約を満たさない場合はストリームのエラーとして
  ///   通知する(購読は継続し、後続のスナップショットで回復しうる)。エラー表現は
  ///   素のStreamのため、購読側はonErrorを必ず指定すること。onErrorには
  ///   Exception(想定内の失敗。エラー状態にする)だけでなくError(実装バグ)も
  ///   届くため、購読側はErrorを握りつぶさず再送出すること
  Stream<List<Property>> watchAll();
}
