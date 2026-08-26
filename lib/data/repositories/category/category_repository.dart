import '../../../domain/models/category.dart';

/// 収入/支出カテゴリを購読するRepository。
///
/// 収入カテゴリと支出カテゴリはモデルの型が分かれている(支出カテゴリだけが
/// 今後予算を持つ)。`watchAll(type)`のような1メソッドに統一すると戻り値が
/// Union型になり、呼び出し側が型で分岐する経路が生まれてしまうため、
/// 種別ごとに別メソッドとする。
abstract interface class CategoryRepository {
  /// 収入カテゴリの一覧を購読する。
  ///
  /// 契約:
  /// - 初回スナップショット(オフラインキャッシュ由来を含む)が届くまで
  ///   何もemitしない(購読側はローディングとして扱える)
  /// - 以降は変更のたびにリスト全体を再emitする
  /// - 並びは規定しない(実装は現状ドキュメントID順で返す)
  /// - ドキュメントがドメインの制約を満たさない場合はストリームのエラーとして
  ///   通知する(購読は継続し、後続のスナップショットで回復しうる)。エラー表現は
  ///   素のStreamのため、購読側はonErrorを必ず指定すること。onErrorには
  ///   Exception(想定内の失敗。エラー状態にする)だけでなくError(実装バグ)も
  ///   届くため、購読側はErrorを握りつぶさず再送出すること
  Stream<List<IncomeCategory>> watchIncomeCategories();

  /// 支出カテゴリの一覧を購読する。契約は[watchIncomeCategories]と同様。
  Stream<List<ExpenseCategory>> watchExpenseCategories();
}
