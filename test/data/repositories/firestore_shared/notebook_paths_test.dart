import 'package:household_accounts/data/repositories/firestore_shared/notebook_paths.dart';
import 'package:household_accounts/domain/models/notebook.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:test/test.dart';

void main() {
  group('notebookPath', () {
    test('個人ノートのとき、personalNotes配下のuidパスであること', () {
      final notebook = Notebook.personal(UserId('user-1'));

      expect(notebookPath(notebook), 'personalNotes/user-1');
    });

    test('共有ノートのとき、sharedNotes配下のpairIdパスであること', () {
      final notebook = Notebook.shared(PairId('pair-1'));

      expect(notebookPath(notebook), 'sharedNotes/pair-1');
    });
  });
}
