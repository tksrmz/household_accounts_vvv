import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../data/repositories/property/property_repository.dart';
import '../../domain/models/property.dart';
import '../../domain/models/property_id.dart';
import '../../utils/command.dart';

/// 資産一覧画面の状態を持つViewModel。
class PropertiesViewModel extends ChangeNotifier {
  PropertiesViewModel({required PropertyRepository propertyRepository}) {
    delete = Command1(propertyRepository.delete);
    // 資産の購読をCommandに載せない理由:
    // Commandは「完了する非同期処理」の実行状態を扱う型であり、完了せず流れ
    // 続ける購読はその型に載らない。購読の結果はこのVMのフィールドで表す。
    _propertiesSubscription = propertyRepository.watchAll().listen(
      _onProperties,
      onError: _onPropertiesError,
    );
  }

  late final StreamSubscription<List<Property>> _propertiesSubscription;

  /// 資産を削除するコマンド。
  ///
  /// 削除の成功で一覧を更新する必要はない(資産の購読が削除を反映する)。
  /// 削除してよいかの確認はUIの関心事なのでViewが行い、このコマンドは確認済みの
  /// 削除だけを受け取る。このコマンドの失敗はデータ層由来の失敗だけを表す。
  late final Command1<void, PropertyId> delete;

  List<Property> _properties = const [];

  /// 表示する資産の一覧。並びはRepositoryの契約(名前の昇順)に従う。
  List<Property> get properties => _properties;

  bool _hasReceivedProperties = false;

  /// 初回の読み込みが完了していないかどうか。
  ///
  /// 購読が失敗した場合はデータが届かずtrueのままになるため、Viewは
  /// [loadError]を先に確認すること。
  bool get isLoading => !_hasReceivedProperties;

  Exception? _loadError;

  /// 購読で発生した想定内の失敗。発生していなければ`null`。
  Exception? get loadError => _loadError;

  void _onProperties(List<Property> properties) {
    _properties = properties;
    _hasReceivedProperties = true;
    // 後続のスナップショットで回復しうるため、正常な発行でエラーを解消する
    _loadError = null;
    notifyListeners();
  }

  /// [Result.guard]と同じ区分(Exception=想定内の失敗/Error=プログラミングバグ)を
  /// Stream購読でも貫く。Errorを状態化せず再送出するのは、実装バグを
  /// エラー表示に隠して気づけなくする事態を避けるため。
  void _onPropertiesError(Object error, StackTrace stackTrace) {
    if (error is! Exception) {
      Error.throwWithStackTrace(error, stackTrace);
    }
    // エラーUIは詳細を表示しないため、原因調査の手がかりをログへ残す
    developer.log(
      '資産の購読が失敗しました',
      name: 'PropertiesViewModel',
      level: Level.WARNING.value,
      error: error,
      stackTrace: stackTrace,
    );
    _loadError = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _propertiesSubscription.cancel();
    super.dispose();
  }
}
