import '../../../domain/models/property.dart';
import '../../../domain/models/property_id.dart';
import '../../../domain/models/property_name.dart';
import '../../../utils/result.dart';

/// 資産を購読・更新するRepository。
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

  /// 資産を新規作成する。IDは自動採番される。
  Future<Result<void>> add({required PropertyName name, required int balance});

  /// 資産[id]のうち、引数で渡したフィールドだけを更新する。
  ///
  /// 契約:
  /// - 渡していないフィールドは書き込まない(編集中に入った残高の増減を
  ///   上書きしないため)
  /// - [name]と[balance]がどちらもnullのときは呼び出し側の不具合として
  ///   [ArgumentError]を送出する([Result]にはしない)
  /// - 対象の資産が存在しないときは失敗([Result.error])になる
  Future<Result<void>> update(
    PropertyId id, {
    PropertyName? name,
    int? balance,
  });

  /// 資産[id]を削除する。
  ///
  /// 契約:
  /// - この資産を参照する記録の有無は確認せず、無条件に削除する。参照していた
  ///   記録は残り、参照先が存在しない記録として「削除済み」と表示され続ける
  /// - 対象の資産が存在しないときも成功とする
  Future<Result<void>> delete(PropertyId id);
}
