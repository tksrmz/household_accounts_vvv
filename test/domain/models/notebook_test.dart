import 'package:household_accounts/domain/models/notebook.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:test/test.dart';

void main() {
  group('生成', () {
    test('Notebook.personalを生成したとき、指定したuidを持つこと', () {
      final notebook = Notebook.personal(UserId('uid'));

      expect(notebook, isA<PersonalNotebook>());
      expect((notebook as PersonalNotebook).uid, UserId('uid'));
    });

    test('Notebook.sharedを生成したとき、指定したpairIdを持つこと', () {
      final notebook = Notebook.shared(PairId('pair-id'));

      expect(notebook, isA<SharedNotebook>());
      expect((notebook as SharedNotebook).pairId, PairId('pair-id'));
    });
  });

  // 値等価がここで重要な理由:
  // ノート切替時にViewがNotebookをValueKeyとして使う想定であり、
  // 同じ内容のNotebookが常に同じキーとして扱われる必要がある。
  group('値等価', () {
    test('同じuidを持つPersonalNotebook同士は等しいこと', () {
      expect(
        Notebook.personal(UserId('uid')),
        Notebook.personal(UserId('uid')),
      );
    });

    test('異なるuidを持つPersonalNotebook同士は等しくないこと', () {
      expect(
        Notebook.personal(UserId('uid-1')),
        isNot(Notebook.personal(UserId('uid-2'))),
      );
    });

    test('同じpairIdを持つSharedNotebook同士は等しいこと', () {
      expect(
        Notebook.shared(PairId('pair-id')),
        Notebook.shared(PairId('pair-id')),
      );
    });

    test('異なるpairIdを持つSharedNotebook同士は等しくないこと', () {
      expect(
        Notebook.shared(PairId('pair-id-1')),
        isNot(Notebook.shared(PairId('pair-id-2'))),
      );
    });

    test('PersonalNotebookとSharedNotebookは等しくないこと', () {
      expect(
        Notebook.personal(UserId('same')),
        isNot(Notebook.shared(PairId('same'))),
      );
    });
  });
}
