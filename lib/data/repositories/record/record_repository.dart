import '../../../domain/models/period.dart';
import '../../../domain/models/record.dart';
import '../../../domain/models/record_content.dart';
import '../../../utils/result.dart';

/// 収入/支出/振替のレコードを購読するRepository。
abstract interface class RecordRepository {
  /// [period](start以上end未満の半開区間)に含まれるレコードを購読する。
  ///
  /// 契約:
  /// - 収入・支出・振替を混在させた1本のストリームを返す
  /// - 3コレクションすべての初回スナップショット(オフラインキャッシュ由来を含む)が
  ///   届くまで何もemitしない(購読側はローディングとして扱える)
  /// - 以降はいずれかのコレクションの変更でリスト全体を再emitする
  /// - 並びは日付の昇順。同じ日付内の順序は規定しない
  /// - ドキュメントがドメインの制約を満たさない場合はストリームのエラーとして
  ///   通知する(購読は継続し、後続のスナップショットで回復しうる)。エラー表現は
  ///   素のStreamのため、購読側はonErrorを必ず指定すること。onErrorには
  ///   Exception(想定内の失敗。エラー状態にする)だけでなくError(実装バグ)も
  ///   届くため、購読側はErrorを握りつぶさず再送出すること
  Stream<List<Record>> watchPeriod(Period period);

  /// [record]を作成し、[RecordContent.balanceEffects]が示す資産残高の増減を
  /// 原子的に行う。
  ///
  /// 契約:
  /// - レコードの作成と資産残高の増減はひとつの書き込み単位として適用され、
  ///   一方だけが反映される部分適用は起きない
  /// - 増減対象の資産(`propertyId`)が存在しない場合は失敗する([Result.error])
  /// - 成功した場合、作成されたレコードは以後の[watchPeriod]の購読へ反映される
  Future<Result<void>> add(RecordContent record);

  /// [record]を削除し、そのレコードが資産残高へ与えていた増減を打ち消す。
  ///
  /// 契約:
  /// - レコードの削除と資産残高の打ち消しはひとつの書き込み単位として適用され、
  ///   一方だけが反映される部分適用は起きない
  /// - 打ち消す金額は削除時点で保存されている値を正とする。[record]が古い内容を
  ///   保持していても、その金額では打ち消さない
  /// - 打ち消し対象の資産が既に存在しない場合、その資産の打ち消しは行わないが
  ///   レコードの削除は成功する
  /// - 対象のレコードが既に存在しない場合は成功として扱う(削除の目的である
  ///   「存在しない」状態は達成されているため)
  /// - 成功した場合、削除されたレコードは以後の[watchPeriod]の購読へ反映される
  Future<Result<void>> delete(Record record);
}
