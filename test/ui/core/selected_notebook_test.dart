import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/notebook.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/ui/core/selected_notebook.dart';

void main() {
  group('updatePairId', () {
    test('pairIdを渡したとき、pairIdが保持されること', () {
      final target = SelectedNotebook();

      target.updatePairId(PairId('pair-id'));

      expect(target.pairId, PairId('pair-id'));
    });

    test('sharedを選択中にpairId=nullを渡したとき、選択中ノートがpersonalへリセットされ通知が1回であること', () {
      final target = SelectedNotebook();
      target.updatePairId(PairId('pair-id'));
      target.select(NotebookKind.shared);
      var notifyCount = 0;
      target.addListener(() => notifyCount++);

      target.updatePairId(null);

      expect(target.kind, NotebookKind.personal);
      expect(target.pairId, isNull);
      expect(notifyCount, 1);
    });

    test('personalを選択中にpairId=nullを渡したとき、選択状態はpersonalのまま変わらないこと', () {
      final target = SelectedNotebook();

      target.updatePairId(null);

      expect(target.kind, NotebookKind.personal);
      expect(target.pairId, isNull);
    });

    test('同値(同じpairId・同じ選択状態)を渡したとき、リスナーへ通知されないこと', () {
      final target = SelectedNotebook();
      target.updatePairId(PairId('pair-id'));
      var notifyCount = 0;
      target.addListener(() => notifyCount++);

      target.updatePairId(PairId('pair-id'));

      expect(notifyCount, 0);
    });

    test('pairIdがnullのまま再度nullを渡したとき、リスナーへ通知されないこと', () {
      final target = SelectedNotebook();
      var notifyCount = 0;
      target.addListener(() => notifyCount++);

      target.updatePairId(null);

      expect(notifyCount, 0);
    });
  });

  group('resolve', () {
    test('personal選択中のとき、PersonalNotebookへ解決されること', () {
      final target = SelectedNotebook();
      final uid = UserId('user-1');

      final notebook = target.resolve(uid);

      expect(notebook, Notebook.personal(uid));
    });

    test('shared選択中でpairId設定済みのとき、SharedNotebookへ解決されること', () {
      final target = SelectedNotebook();
      target.updatePairId(PairId('pair-id'));
      target.select(NotebookKind.shared);

      final notebook = target.resolve(UserId('user-1'));

      expect(notebook, Notebook.shared(PairId('pair-id')));
    });

    test('shared選択中だがpairId未設定のとき、Error系がthrowされること', () {
      final target = SelectedNotebook();
      target.select(NotebookKind.shared);

      expect(() => target.resolve(UserId('user-1')), throwsA(isA<Error>()));
    });
  });
}
