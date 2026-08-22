// test_reflective_loaderの規約上、テストメソッド名の`test_`接頭辞に続く部分で
// 大文字始まりの単語を連ねる(lowerCamelCaseに従わない)命名になるため無効化する。
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:household_lints/src/rules/repository_no_public_properties.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryNoPublicPropertiesTest);
    defineReflectiveTests(RepositoryNoPublicPropertiesOutsideTargetDirTest);
  });
}

/// 検証対象ディレクトリ(`lib/data/repositories/`配下)にあるファイルへの適用を検証する。
@reflectiveTest
class RepositoryNoPublicPropertiesTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryNoPublicProperties();
    super.setUp();
  }

  // 既定のtestFileNameは`test.dart`(lib直下)なので、このルールが対象とする
  // `lib/data/repositories/`配下を再現するために上書きする。
  @override
  String get testFileName => 'data/repositories/auth/fake_repository.dart';

  /// 公開getterは、違反として検知されること。
  void test_publicGetter_isReported() async {
    final source = '''
class FakeRepository {
  int get counter => 0;
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('counter'), 'counter'.length),
    ]);
  }

  /// 公開setterは、違反として検知されること。
  void test_publicSetter_isReported() async {
    final source = '''
class FakeRepository {
  set counter(int value) {}
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('counter'), 'counter'.length),
    ]);
  }

  /// 公開フィールドは、違反として検知されること。
  void test_publicField_isReported() async {
    final source = '''
class FakeRepository {
  int counter = 0;
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('counter'), 'counter'.length),
    ]);
  }

  /// 公開staticなconstフィールドは、違反として検知されること
  /// (instance/static、final/constを問わず対象であるため)。
  void test_publicStaticConstField_isReported() async {
    final source = '''
class FakeRepository {
  static const int maxRetryCount = 3;
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('maxRetryCount'), 'maxRetryCount'.length),
    ]);
  }

  /// 抽象interfaceの公開getter宣言(本体なし)も、違反として検知されること。
  void test_abstractGetter_isReported() async {
    final source = '''
abstract class FakeRepository {
  int get counter;
}
''';
    await assertDiagnostics(source, [
      lint(source.indexOf('counter'), 'counter'.length),
    ]);
  }

  /// 公開メソッドは、検知されないこと(Repositoryの公開APIとして許容する形)。
  void test_publicMethod_isNotReported() async {
    final source = '''
class FakeRepository {
  int fetchCounter() => 0;
}
''';
    await assertNoDiagnostics(source);
  }

  /// privateフィールド("_"始まり)は、検知されないこと。
  void test_privateField_isNotReported() async {
    final source = '''
class FakeRepository {
  int _counter = 0;
}
''';
    await assertNoDiagnostics(source);
  }

  /// privateのgetterは、検知されないこと。
  void test_privateGetter_isNotReported() async {
    final source = '''
class FakeRepository {
  int get _counter => 0;
}
''';
    await assertNoDiagnostics(source);
  }

  /// コンストラクタは、検知対象外であること。
  void test_constructor_isNotReported() async {
    final source = '''
class FakeRepository {
  FakeRepository();
}
''';
    await assertNoDiagnostics(source);
  }

  /// クラス名が`Repository`で終わらない(DTO等を想定した)クラスは、
  /// 公開フィールドとgetterを持っていても検知対象外であること。
  void test_classNameNotEndingWithRepository_isNotReported() async {
    final source = '''
class RecordDto {
  int counter = 0;
  int get doubled => counter * 2;
}
''';
    await assertNoDiagnostics(source);
  }
}

/// `lib/data/repositories/`外のファイルには適用されないことを検証する。
@reflectiveTest
class RepositoryNoPublicPropertiesOutsideTargetDirTest
    extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RepositoryNoPublicProperties();
    super.setUp();
  }

  // testFileNameは既定(`test.dart`、lib直下)のまま
  // = `lib/data/repositories/`配下ではないパスになる。

  /// `lib/data/repositories/`外にある同形のコード(公開フィールド)は、
  /// 検知対象外であること。
  void test_fileOutsideRepositoriesDir_isNotReported() async {
    final source = '''
class FakeRepository {
  int counter = 0;
}
''';
    await assertNoDiagnostics(source);
  }
}
