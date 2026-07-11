import 'package:dartz/dartz.dart';

import '../models/expense_category.dart';
import '../models/vo/category_id.dart';

/// 支出カテゴリのリポジトリインターフェース
abstract interface class ExpenseCategoryRepository {
  /// すべての支出カテゴリを取得する
  ///
  /// 返却されるListの順番については保証されない。
  Future<Either<Exception, List<ExpenseCategoryModel>>> fetchAll();

  /// 支出カテゴリを追加する
  ///
  /// [category] 追加する支出カテゴリ
  Future<Either<Exception, Unit>> add(ExpenseCategoryModel category);

  /// 支出カテゴリを更新する
  ///
  /// [id] 更新対象のカテゴリID
  /// [category] 更新後の支出カテゴリデータ
  Future<Either<Exception, Unit>> update(
      CategoryIdVo id, ExpenseCategoryModel category);

  /// 支出カテゴリを削除する
  ///
  /// [id] 削除対象のカテゴリID
  Future<Either<Exception, Unit>> delete(CategoryIdVo id);
}
