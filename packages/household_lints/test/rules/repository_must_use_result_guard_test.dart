// test_reflective_loaderの規約上、テストメソッド名の`test_`接頭辞に続く部分で
// 大文字始まりの単語を連ねる(lowerCamelCaseに従わない)命名になるため無効化する。
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:household_lints/src/rules/repository_must_use_result_guard.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryMustUseResultGuardTest);
    defineReflectiveTests(RepositoryMustUseResultGuardOutsideTargetDirTest);
  });
}

/// 実アプリの`lib/utils/result.dart`と同じ形の`Result`型のフィクスチャ。
///
/// アプリ本体(Flutter)への依存を避けるため、テスト用パッケージ内に
/// スタブとして定義し、検証対象のソースからimportして使う。
/// 検証対象ソースへ直接埋め込まず実アプリと同じ`lib/utils/`配下の
/// 別ファイルに置くのは、`lib/data/repositories/`配下に埋め込むと
/// スタブ自身の`static guard`(本体がtry/catchそのもの)が
/// ルールに検知されてしまうため。
const _resultStub = '''
sealed class Result<T> {
  const Result();
  const factory Result.ok(T value) = Ok._;
  const factory Result.error(Exception error) = Error._;

  static Future<Result<T>> guard<T>(Future<T> Function() run) async {
    try {
      return Result.ok(await run());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error._(this.error);
  final Exception error;
}
''';

/// 検証対象ディレクトリ(`lib/data/repositories/`配下)にあるファイルへの適用を検証する。
///
/// テスト名は`test_reflective_loader`の規約上メソッド名(ASCII)そのものが
/// テスト説明を兼ねるため英語表記とし、日本語の仕様(前提/期待値)は
/// 各テスト直前のdocコメントに記述する(Test as Documentationの方針は
/// docコメント側で満たす)。
@reflectiveTest
class RepositoryMustUseResultGuardTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryMustUseResultGuard();
    super.setUp();
    newFile('$testPackageLibPath/utils/result.dart', _resultStub);
  }

  // 既定のtestFileNameは`test.dart`(lib直下)なので、このルールが対象とする
  // `lib/data/repositories/`配下を再現するために上書きする。
  @override
  String get testFileName => 'data/repositories/auth/fake_repository.dart';

  /// 公開の`Future<Result<void>>`メソッドがResult.guardを使わず
  /// try/catchを手書きしているとき、違反として検知されること。
  void test_handWrittenTryCatch_isReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> signOut() async {
    try {
      return Result.ok(await Future<void>.value());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('signOut'), 'signOut'.length),
    ]);
  }

  /// ブロック本体が`return Result.guard(...);`の前に別の文を持つ
  /// (単一のreturn文ではない)とき、違反として検知されること。
  void test_multiStatementBlockBody_isReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> signOut() {
    _log();
    return Result.guard(() => Future<void>.value());
  }

  void _log() {}
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('signOut'), 'signOut'.length),
    ]);
  }

  /// async修飾つきの本体は`await Result.guard(...)`を返していても
  /// 「Result.guard(...)の直接返し」ではないため、違反として検知されること。
  void test_asyncBodyAwaitingResultGuard_isReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> signOut() async =>
      await Result.guard(() => Future<void>.value());
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('signOut'), 'signOut'.length),
    ]);
  }

  /// 式本体`=> Result.guard(...)`で直接返しているとき、検知されないこと。
  void test_expressionBodyReturningResultGuard_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> signOut() => Result.guard(() => Future<void>.value());
}
''';
    await assertNoDiagnostics(source);
  }

  /// ブロック本体が`return Result.guard(...);`という単一の文のみのとき、
  /// 検知されないこと。
  void test_singleReturnStatementBlockBody_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> signOut() {
    return Result.guard(() => Future<void>.value());
  }
}
''';
    await assertNoDiagnostics(source);
  }

  /// privateメソッド("_"始まり)は、違反と同じ形(try/catch手書き)であっても
  /// 検知対象外であること。
  void test_privateMethod_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> _signOut() async {
    try {
      return Result.ok(await Future<void>.value());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
''';
    await assertNoDiagnostics(source);
  }

  /// staticメソッドであっても公開メソッドである以上は検知対象であること
  /// (判定基準は公開/非公開であり、static/インスタンスの別ではない)。
  void test_staticMethod_isReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  static Future<Result<void>> signOut() async {
    try {
      return Result.ok(await Future<void>.value());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('signOut'), 'signOut'.length),
    ]);
  }

  /// 本体を持たない抽象メソッドは検知対象外であること。
  void test_abstractMethod_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

abstract class FakeRepository {
  Future<Result<void>> signOut();
}
''';
    await assertNoDiagnostics(source);
  }

  /// 宣言返り値型が`Future<Result<...>>`ではないメソッドは、
  /// 違反と同じ形(try/catch手書き)であっても検知対象外であること。
  void test_nonResultReturnType_isNotReported() async {
    final source = '''
class FakeRepository {
  Future<void> signOut() async {
    try {
      await Future<void>.value();
    } on Exception {
      rethrow;
    }
  }
}
''';
    await assertNoDiagnostics(source);
  }

  /// getterは、違反と同じ形であっても検知対象外であること。
  void test_getter_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> get pending {
    final future = Result.guard(() => Future<void>.value());
    return future;
  }
}
''';
    await assertNoDiagnostics(source);
  }
}

/// `lib/data/repositories/`外のファイルには適用されないことを検証する。
@reflectiveTest
class RepositoryMustUseResultGuardOutsideTargetDirTest
    extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryMustUseResultGuard();
    super.setUp();
    newFile('$testPackageLibPath/utils/result.dart', _resultStub);
  }

  // testFileNameは既定(`test.dart`、lib直下)のまま
  // = `lib/data/repositories/`配下ではないパスになる。

  /// `lib/data/repositories/`外にある同形のコード(try/catch手書き)は、
  /// 検知対象外であること。
  void test_fileOutsideRepositoriesDir_isNotReported() async {
    final source = '''
import 'utils/result.dart';

class FakeRepository {
  Future<Result<void>> signOut() async {
    try {
      return Result.ok(await Future<void>.value());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
''';
    await assertNoDiagnostics(source);
  }
}
