import '../../../domain/models/budget.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/category_id.dart';
import '../../../domain/models/category_name.dart';
import '../../../utils/result.dart';

/// 収入/支出カテゴリを購読・更新するRepository。
///
/// 収入カテゴリと支出カテゴリはモデルの型が分かれている(支出カテゴリだけが
/// 予算を持つ)。`watchAll(type)`のような1メソッドに統一すると戻り値が
/// Union型になり、呼び出し側が型で分岐する経路が生まれてしまうため、
/// 購読・追加・更新・削除のいずれも種別ごとに別メソッドとする。
abstract interface class CategoryRepository {
  /// 収入カテゴリの一覧を購読する。
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
  Stream<List<IncomeCategory>> watchIncomeCategories();

  /// 支出カテゴリの一覧を購読する。契約は[watchIncomeCategories]と同様
  /// (予算がドメインの制約を満たさない場合もストリームのエラーになる)。
  Stream<List<ExpenseCategory>> watchExpenseCategories();

  /// 収入カテゴリを新規作成する。IDは自動採番される。
  Future<Result<void>> addIncomeCategory(CategoryName name);

  /// 支出カテゴリを新規作成する。IDは自動採番される。
  Future<Result<void>> addExpenseCategory({
    required CategoryName name,
    required Budget budget,
  });

  /// 収入カテゴリ[id]の名前を更新する。
  ///
  /// 対象のカテゴリが存在しないときは失敗([Result.error])になる。
  Future<Result<void>> updateIncomeCategory(
    CategoryId id, {
    required CategoryName name,
  });

  /// 支出カテゴリ[id]のうち、引数で渡したフィールドだけを更新する。
  ///
  /// 契約:
  /// - 渡していないフィールドは書き込まない(編集中に他の端末やペア相手が
  ///   行った変更を、開いた時点の値で上書きしないため)
  /// - [name]と[budget]がどちらもnullのときは呼び出し側の不具合として
  ///   [ArgumentError]を送出する([Result]にはしない)
  /// - 対象のカテゴリが存在しないときは失敗([Result.error])になる
  Future<Result<void>> updateExpenseCategory(
    CategoryId id, {
    CategoryName? name,
    Budget? budget,
  });

  /// 収入カテゴリ[id]を削除する。
  ///
  /// 契約:
  /// - このカテゴリを参照する記録の有無は確認せず、無条件に削除する。参照していた
  ///   記録は残り、参照先が存在しない記録として「削除済み」と表示され続ける
  /// - 対象のカテゴリが存在しないときも成功とする
  Future<Result<void>> deleteIncomeCategory(CategoryId id);

  /// 支出カテゴリ[id]を削除する。契約は[deleteIncomeCategory]と同様。
  Future<Result<void>> deleteExpenseCategory(CategoryId id);
}
