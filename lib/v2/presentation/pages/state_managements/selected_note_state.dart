import 'package:flutter/foundation.dart';

// このクラスは移行期間中の一時的な置き場所である。新アーキテクチャの
// domain/modelsに属する概念(選択中ノートの状態)を旧v2配下に置いたまま
// domain/modelsのPairId/Notebookへ依存させている。後始末で新アーキテクチャの
// 最終形(SelectedNotebook)へ改名・移設する予定であり、それまでの意図的な依存である。
import '../../../../domain/models/notebook.dart';
import '../../../../domain/models/pair_id.dart';
import '../../../../domain/models/user_id.dart';

class SelectedNoteState extends ChangeNotifier {
  SelectedNoteState() : _value = SelectedNote.personal, _pairId = null;

  SelectedNote _value;
  PairId? _pairId;

  SelectedNote get value => _value;

  bool get isPersonal => _value == SelectedNote.personal;

  /// 現在のペアID。ペアが存在しなければ`null`。
  PairId? get pairId => _pairId;

  void select(SelectedNote newValue) {
    _value = newValue;
    notifyListeners();
  }

  /// ペア検知の結果([pairId])を反映する。
  ///
  /// ペア解消(pairIdの消失)時に選択中ノートがsharedのまま残ると共有ノートを
  /// 解決できなくなるため、pairIdの消失とpersonalへのリセットを1回の通知で
  /// 原子的に行う(2回に分けると通知の間に不整合な状態が観測される)。
  void updatePairId(PairId? pairId) {
    final nextValue = pairId == null ? SelectedNote.personal : _value;
    if (_pairId == pairId && _value == nextValue) return;
    _pairId = pairId;
    _value = nextValue;
    notifyListeners();
  }

  /// 選択中ノートを[uid]の文脈で[Notebook]へ解決する。
  ///
  /// sharedなのにpairIdがnullなのは呼び出し順の不具合であり、切替UIは
  /// ペア検知が完了して初めて有効になるため正常系では起きない。したがって
  /// ここではnull checkエラーでそのままfail fastさせる。
  Notebook resolve(UserId uid) => switch (_value) {
    SelectedNote.personal => Notebook.personal(uid),
    SelectedNote.shared => Notebook.shared(_pairId!),
  };
}

enum SelectedNote { personal, shared }
