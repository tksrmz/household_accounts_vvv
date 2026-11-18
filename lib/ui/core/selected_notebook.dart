import 'package:flutter/foundation.dart';

import '../../domain/models/notebook.dart';
import '../../domain/models/pair_id.dart';
import '../../domain/models/user_id.dart';

/// 選択中のノート(個人/共有)とペアIDを保持する、複数画面にまたがるUI状態。
class SelectedNotebook extends ChangeNotifier {
  SelectedNotebook() : _kind = NotebookKind.personal, _pairId = null;

  NotebookKind _kind;
  PairId? _pairId;

  NotebookKind get kind => _kind;

  /// 現在のペアID。ペアが存在しなければ`null`。
  PairId? get pairId => _pairId;

  void select(NotebookKind newKind) {
    _kind = newKind;
    notifyListeners();
  }

  /// ペア検知の結果([pairId])を反映する。
  ///
  /// ペア解消(pairIdの消失)時に選択中ノートがsharedのまま残ると共有ノートを
  /// 解決できなくなるため、pairIdの消失とpersonalへのリセットを1回の通知で
  /// 原子的に行う(2回に分けると通知の間に不整合な状態が観測される)。
  void updatePairId(PairId? pairId) {
    final nextKind = pairId == null ? NotebookKind.personal : _kind;
    if (_pairId == pairId && _kind == nextKind) return;
    _pairId = pairId;
    _kind = nextKind;
    notifyListeners();
  }

  /// 選択中ノートを[uid]の文脈で[Notebook]へ解決する。
  ///
  /// sharedなのにpairIdがnullなのは呼び出し順の不具合であり、切替UIは
  /// ペア検知が完了して初めて有効になるため正常系では起きない。したがって
  /// ここではnull checkエラーでそのままfail fastさせる。
  Notebook resolve(UserId uid) => switch (_kind) {
    NotebookKind.personal => Notebook.personal(uid),
    NotebookKind.shared => Notebook.shared(_pairId!),
  };
}

/// 選択できるノートの種類。
enum NotebookKind { personal, shared }
