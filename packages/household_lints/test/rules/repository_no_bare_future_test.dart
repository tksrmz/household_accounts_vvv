// test_reflective_loaderの規約上、テストメソッド名の`test_`接頭辞に続く部分で
// 大文字始まりの単語を連ねる(lowerCamelCaseに従わない)命名になるため無効化する。
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:household_lints/src/rules/repository_no_bare_future.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryNoBareFutureTest);
    defineReflectiveTests(RepositoryNoBareFutureOutsideTargetDirTest);
  });
}

/// 実アプリの`lib/utils/result.dart`と同じ形の`Result`型のフィクスチャ。
///
/// `repository_must_use_result_guard_test.dart`と同じ理由
/// (`lib/data/repositories/`配下に埋め込むとスタブ自身がルールに検知されうるため)で、
/// テスト用パッケージ内の`lib/utils/`配下に別ファイルとして配置する。
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
@reflectiveTest
class RepositoryNoBareFutureTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryNoBareFuture();
    super.setUp();
    newFile('$testPackageLibPath/utils/result.dart', _resultStub);
  }

  // 既定のtestFileNameは`test.dart`(lib直下)なので、このルールが対象とする
  // `lib/data/repositories/`配下を再現するために上書きする。
  @override
  String get testFileName => 'data/repositories/auth/fake_repository.dart';

  /// 公開メソッドが`Future<void>`(素のFuture)を返すとき、違反として検知されること。
  void test_bareFutureVoid_isReported() async {
    final source = '''
class FakeRepository {
  Future<void> fetchToken() async {}
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchToken'), 'fetchToken'.length),
    ]);
  }

  /// 公開メソッドがResultでない型を包む`Future<T>`を返すとき、違反として検知されること。
  void test_bareFutureNonResultType_isReported() async {
    final source = '''
class FakeRepository {
  Future<String> fetchToken() async => 'token';
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchToken'), 'fetchToken'.length),
    ]);
  }

  /// `FutureOr<Result<T>>`は、型引数がResultであっても違反として検知されること。
  /// RepositoryのAPIとしては`Future<Result<T>>`に統一するため、FutureOrは
  /// 型引数を問わず一律禁止する。
  void test_futureOrOfResult_isReported() async {
    final source = '''
import 'dart:async';

import '../../../utils/result.dart';

class FakeRepository {
  FutureOr<Result<int>> fetchCount() => Result.ok(1);
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchCount'), 'fetchCount'.length),
    ]);
  }

  /// 抽象interfaceの`Future<void>`宣言(本体なし)も、違反として検知されること。
  /// interfaceの宣言こそAPIの形そのものであり、実装を待たず宣言時点で
  /// 検証する必要があるため。
  void test_abstractMethodBareFuture_isReported() async {
    final source = '''
abstract class FakeRepository {
  Future<void> fetchToken();
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchToken'), 'fetchToken'.length),
    ]);
  }

  /// staticな公開メソッドであっても、素のFutureを返せば違反として検知されること
  /// (判定基準は公開/非公開であり、static/インスタンスの別ではない)。
  void test_staticBareFuture_isReported() async {
    final source = '''
class FakeRepository {
  static Future<void> fetchToken() async {}
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchToken'), 'fetchToken'.length),
    ]);
  }

  /// 返り値型の注釈を省略し、`Repository`で終わらないinterface
  /// (`TokenSource`)の型を継承してオーバーライドする実装であっても、
  /// 宣言要素としての返り値型(オーバーライド推論の結果)が素の`Future<T>`
  /// であれば、実装側(`FakeRepository`)は違反として検知されること。
  /// interface宣言側(`TokenSource`、クラス名が`Repository`で終わらない)は
  /// スコープ判定により対象外のまま。
  void test_implicitReturnTypeFromNonRepositoryInterface_isReported() async {
    final source = '''
abstract class TokenSource {
  Future<String> fetchToken();
}

class FakeRepository implements TokenSource {
  fetchToken() async => '';
}
''';
    await assertDiagnostics(source, [
      lint(source.lastIndexOf('fetchToken'), 'fetchToken'.length),
    ]);
  }

  /// `Future<Result<void>?>`(型引数のResult自体がnullable)は、
  /// 違反として検知されること。nullableなResultはOk/Errorという契約を
  /// 壊すため、Repositoryの公開APIとしては許容しない。
  void test_futureOfNullableResult_isReported() async {
    final source = '''
import '../../../utils/result.dart';

abstract class FakeRepository {
  Future<Result<void>?> fetchMaybe();
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchMaybe'), 'fetchMaybe'.length),
    ]);
  }

  /// `Future<Result<void>>?`(Future自体がnullable)は、
  /// 違反として検知されること。
  void test_nullableFutureOfResult_isReported() async {
    final source = '''
import '../../../utils/result.dart';

abstract class FakeRepository {
  Future<Result<void>>? fetchMaybe();
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchMaybe'), 'fetchMaybe'.length),
    ]);
  }

  /// ファイル内でローカルに`Result`という名前のクラスを定義している場合、
  /// アプリの`lib/utils/result.dart`のResultとは別物とみなし、
  /// (Resultでラップされていない)素のFutureとして違反になること。
  void test_localResultClass_isReported() async {
    final source = '''
class Result<T> {
  const Result(this.value);
  final T value;
}

class FakeRepository {
  Future<Result<int>> fetchCount() async => Result(1);
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchCount'), 'fetchCount'.length),
    ]);
  }

  /// `dynamic`を明示した公開メソッドが`async`本体を持つとき、違反として
  /// 検知されること。`dynamic`は型ベースの判定(`InterfaceType`のFuture/
  /// FutureOr)をすり抜けるが、`async`な本体は実行時に必ずFutureを返し、
  /// 失敗がResultの契約の外へ逃げるため、本体の非同期性で補足する。
  void test_dynamicReturnTypeWithAsyncBody_isReported() async {
    final source = '''
class FakeRepository {
  dynamic fetchToken() async => null;
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchToken'), 'fetchToken'.length),
    ]);
  }

  /// interfaceを持たず返り値型注釈も省略した`async`本体の公開メソッドは、
  /// 宣言要素の返り値型が`dynamic`になり型ベースの判定をすり抜けるが、
  /// 違反として検知されること。
  void test_implicitDynamicReturnTypeWithAsyncBody_isReported() async {
    final source = '''
class FakeRepository {
  fetchToken() async {}
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('fetchToken'), 'fetchToken'.length),
    ]);
  }

  /// `void`を明示した`async`本体(fire-and-forget)は、違反として検知される
  /// こと。呼び出し側が結果を待たない書き方であっても、内部で失敗した例外は
  /// 握り潰されてResultの契約の外へ逃げるため許容しない。
  void test_voidReturnTypeWithAsyncBody_isReported() async {
    final source = '''
class FakeRepository {
  void refresh() async {}
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('refresh'), 'refresh'.length),
    ]);
  }

  /// operatorであっても、素のFutureを返せば違反として検知されること
  /// (operatorもRepositoryの公開APIの一部であるため)。
  void test_operatorBareFuture_isReported() async {
    final source = '''
class FakeRepository {
  Future<String> operator [](int index) async => '';
}
''';
    await assertDiagnostics(source, [lint(source.indexOf('['), '[]'.length)]);
  }

  /// `Future<Result<void>>`を返すとき、検知されないこと。
  void test_futureOfResult_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> signOut() => Result.guard(() => Future<void>.value());
}
''';
    await assertNoDiagnostics(source);
  }

  /// `Stream<T>`は型引数を問わず検知されないこと
  /// (Streamの扱いは今回のスコープ外のため素通しする)。
  void test_streamReturnType_isNotReported() async {
    final source = '''
class FakeRepository {
  Stream<int> watchCount() async* {
    yield 1;
  }
}
''';
    await assertNoDiagnostics(source);
  }

  /// 同期の素のTを返すメソッド(`AuthRepository.getCurrentUser()`相当)は、
  /// 検知されないこと。Resultは「失敗しうる操作」のマーカーであり、
  /// 失敗しない同期読み取りまで塞ぐものではない。
  void test_syncPlainReturnType_isNotReported() async {
    final source = '''
class FakeRepository {
  String getCurrentUser() => 'uid';
}
''';
    await assertNoDiagnostics(source);
  }

  /// `dynamic`を返す同期メソッドは、検知されないこと。本体ベースの判定は
  /// `async`(generatorを除く)な本体だけを対象とするため、同期メソッドは
  /// 型が`dynamic`であっても影響を受けない。
  void test_syncDynamicReturnType_isNotReported() async {
    final source = '''
class FakeRepository {
  dynamic parse() => null;
}
''';
    await assertNoDiagnostics(source);
  }

  /// `Future<Result<void>>`を返す適合形の`async`メソッドは、検知されない
  /// こと。本体ベースの判定を追加しても、型ベースの判定で適合形と確認できた
  /// 時点で本体ベースの判定は行わないため、誤検知しない。
  void test_asyncFutureOfResult_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Future<Result<void>> m() async {
    return Result.ok(null);
  }
}
''';
    await assertNoDiagnostics(source);
  }

  /// 同期で`Result<T>`を返すメソッドは、検知されないこと。
  void test_syncResultReturnType_isNotReported() async {
    final source = '''
import '../../../utils/result.dart';

class FakeRepository {
  Result<int> parse(String input) => Result.ok(int.parse(input));
}
''';
    await assertNoDiagnostics(source);
  }

  /// privateメソッド("_"始まり)は、素のFutureを返す形であっても
  /// 検知対象外であること。
  void test_privateMethod_isNotReported() async {
    final source = '''
class FakeRepository {
  Future<void> _fetchToken() async {}
}
''';
    await assertNoDiagnostics(source);
  }

  /// クラス名が`Repository`で終わらない(DTO等を想定した)クラスは、
  /// 素のFutureを返す形であっても検知対象外であること。
  void test_classNameNotEndingWithRepository_isNotReported() async {
    final source = '''
class RecordDto {
  Future<void> fetchToken() async {}
}
''';
    await assertNoDiagnostics(source);
  }
}

/// `lib/data/repositories/`外のファイルには適用されないことを検証する。
@reflectiveTest
class RepositoryNoBareFutureOutsideTargetDirTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryNoBareFuture();
    super.setUp();
  }

  // testFileNameは既定(`test.dart`、lib直下)のまま
  // = `lib/data/repositories/`配下ではないパスになる。

  /// `lib/data/repositories/`外にある同形のコード(素のFuture)は、
  /// 検知対象外であること。
  void test_fileOutsideRepositoriesDir_isNotReported() async {
    final source = '''
class FakeRepository {
  Future<void> fetchToken() async {}
}
''';
    await assertNoDiagnostics(source);
  }
}
