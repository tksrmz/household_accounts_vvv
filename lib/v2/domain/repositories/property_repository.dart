import 'package:dartz/dartz.dart';

import '../models/property.dart';
import '../models/vo/property_id.dart';

/// 資産のリポジトリインターフェース
abstract interface class PropertyRepository {
  /// すべての資産を取得する
  ///
  /// 返却されるListの順番については保証されない。
  Future<Either<Exception, List<PropertyModel>>> fetchAll();

  /// 資産を追加する
  ///
  /// [property] 追加する資産
  Future<Either<Exception, Unit>> add(PropertyModel property);

  /// 資産を更新する
  ///
  /// [id] 更新対象の資産ID
  /// [property] 更新後の資産データ
  Future<Either<Exception, Unit>> update(
      PropertyIdVo id, PropertyModel property);

  /// 資産を削除する
  ///
  /// [id] 削除対象の資産ID
  Future<Either<Exception, Unit>> delete(PropertyIdVo id);
}
