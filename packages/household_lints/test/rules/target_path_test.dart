import 'package:household_lints/src/rules/target_path.dart';
import 'package:test/test.dart';

void main() {
  group('isRepositoryImplementationPath', () {
    test('POSIX区切りでlib/data/repositories配下のパスのとき、trueであること', () {
      const path = '/home/runner/work/repo/lib/data/repositories/auth/foo.dart';
      expect(isRepositoryImplementationPath(path), isTrue);
    });

    test(r'Windows区切り(\)でlib\data\repositories配下のパスのとき、trueであること', () {
      const path =
          r'C:\Users\tk\ws\household_accounts_claude\lib\data\repositories\auth\foo.dart';
      expect(isRepositoryImplementationPath(path), isTrue);
    });

    test('相対パスでlib/data/repositoriesから始まるとき、trueであること', () {
      const path = 'lib/data/repositories/auth/foo.dart';
      expect(isRepositoryImplementationPath(path), isTrue);
    });

    test('lib/data/repositories配下ではないパスのとき、falseであること', () {
      const path = '/home/runner/work/repo/lib/data/firebase/foo.dart';
      expect(isRepositoryImplementationPath(path), isFalse);
    });

    test('lib/repositoriesのようにdataを挟まないパスのとき、falseであること', () {
      const path = '/home/runner/work/repo/lib/repositories/foo.dart';
      expect(isRepositoryImplementationPath(path), isFalse);
    });

    test('repositoriesという名前のファイル(ディレクトリではない)のとき、falseであること', () {
      const path = '/repo/lib/data/repositories.dart';
      expect(isRepositoryImplementationPath(path), isFalse);
    });

    test('test配下のlib/data/repositories風パス(実運用では起こらない想定)でも、trueであること', () {
      // セグメント一致のみで判定する仕様であることの確認
      // (先頭に何が付いていても`lib/data/repositories`が連続していれば対象と見なす)。
      const path = '/repo/test/fixtures/lib/data/repositories/foo.dart';
      expect(isRepositoryImplementationPath(path), isTrue);
    });
  });

  group('isRepositoryClassName', () {
    test('Repositoryで終わるクラス名のとき、trueであること', () {
      expect(isRepositoryClassName('FirebaseAuthRepository'), isTrue);
    });

    test('Repositoryで終わらないクラス名のとき、falseであること', () {
      expect(isRepositoryClassName('RecordDto'), isFalse);
    });

    test('Repositoryを含むが末尾ではないクラス名のとき、falseであること', () {
      expect(isRepositoryClassName('RepositoryHelper'), isFalse);
    });
  });
}
