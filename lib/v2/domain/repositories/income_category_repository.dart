import 'package:dartz/dartz.dart';

import '../models/income_category.dart';
import '../models/vo/category_id.dart';

/// 収入カテゴリのリポジトリインターフェース
abstract interface class IncomeCategoryRepository {
  /// すべての収入カテゴリを取得する
  ///
  /// 返却されるListの順番については保証されない。
  Future<Either<Exception, List<IncomeCategoryVo>>> fetchAll();

  /// 収入カテゴリを追加する
  ///
  /// [category] 追加する収入カテゴリ
  Future<Either<Exception, Unit>> add(IncomeCategoryVo category);

  /// 収入カテゴリを更新する
  ///
  /// [id] 更新対象のカテゴリID
  /// [category] 更新後の収入カテゴリデータ
  Future<Either<Exception, Unit>> update(CategoryIdVo id, IncomeCategoryVo category);

  /// 収入カテゴリを削除する
  ///
  /// [id] 削除対象のカテゴリID
  Future<Either<Exception, Unit>> delete(CategoryIdVo id);
}