import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import 'result_type.dart';
import 'target_path.dart';

/// Repository実装(`lib/data/repositories/`配下かつクラス/mixin名が`Repository`で
/// 終わる宣言)の公開メソッドが、素の`Future`/`FutureOr`を返さないことを
/// 機械検証するルール。
///
/// 規約: Repositoryの公開APIは失敗しうる非同期操作を`Future<Result<T>>`に統一する。
/// 素の`Future<T>`(Resultでラップしていない)や`FutureOr<...>`を返せてしまうと、
/// `repository_must_use_result_guard`(`Future<Result<...>>`を返すメソッドが対象)の
/// 検査対象から外れてしまい、規約の抜け道になるため禁止する。
/// なお、失敗しない同期の読み取り(例: `AuthRepository.getCurrentUser()`)まで
/// 塞ぐものではない。Resultは「失敗しうる操作」のマーカーであり、同期の素のTは
/// 引き続き許容する。
///
/// 型ベースの判定に加えて、メソッド本体が`async`(generatorを除く)かどうかも
/// 見る。`dynamic fetch() async => ...`や、interfaceを持たず返り値型注釈も
/// 省略した実装(要素の返り値型が`dynamic`になる)、`void ... async {}`
/// (fire-and-forget)は、宣言/推論された返り値型が`InterfaceType`の
/// Future/FutureOrにならないため型ベースの判定だけではすり抜けてしまう。
/// しかし`async`な本体は実行時には必ず(素の)`Future`を返し、失敗はResultの
/// 契約の外へ逃げてしまうため、本体の非同期性そのものを違反の手がかりとして
/// 補う。
class RepositoryNoBareFuture extends AnalysisRule {
  RepositoryNoBareFuture()
    : super(
        name: ruleName,
        description:
            'Repositoryの公開メソッドは素のFuture/FutureOrを返さず、'
            'Future<Result<T>>に統一する。',
      );

  static const ruleName = 'repository_no_bare_future';

  // 既定のLintCodeはINFO重大度だが、この規約はCIで確実に検知したいため
  // ERROR重大度で報告する(analyzeの終了コードを違反の有無に連動させるため)。
  static const LintCode code = LintCode(
    ruleName,
    'Repositoryの公開メソッドは素のFuture/FutureOrを返さない'
    '(失敗をResultで表現できず、Result.guard規約の対象からも外れるため)。',
    correctionMessage:
        '返り値をFuture<Result<T>>にし、本体をResult.guard(() => ...)の'
        '直接返しにすること。',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodDeclaration(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final RepositoryNoBareFuture rule;
  final RuleContext context;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final path = context.currentUnit?.file.path;
    if (!isRepositoryApiDeclaration(node, path)) {
      return;
    }
    if (!_isTargetMethod(node)) {
      return;
    }
    if (!_violatesBareFuture(node)) {
      return;
    }
    rule.reportAtToken(node.name);
  }

  /// 検証対象: 公開("_"始まりでない)メソッド。
  /// getter/setterは対象外(Repositoryの公開APIの形は
  /// `repository_no_public_properties`側の関心)。operatorは公開APIの
  /// 一部であるため対象に含める(operatorの名前は`[]`等であり、"_"始まりには
  /// なりえないため、公開/非公開の判定に特別扱いは不要)。
  /// 本体の有無は問わない。抽象メソッド(interfaceの宣言)こそAPIの形
  /// そのものであり、実装だけでなく宣言時点で規約を検証する必要がある。
  bool _isTargetMethod(MethodDeclaration node) {
    if (node.isGetter || node.isSetter) return false;
    if (node.name.lexeme.startsWith('_')) return false;
    return true;
  }

  /// [node]の「宣言要素」としての返り値型を返す。
  /// 構文上の`node.returnType?.type`ではなくこちらを使うのは、
  /// 返り値型の注釈を省略してinterfaceの型を継承するオーバーライドを
  /// すり抜けさせないため(`repository_must_use_result_guard`と同じ方針)。
  DartType? _declaredReturnType(MethodDeclaration node) {
    return node.declaredFragment?.element.returnType;
  }

  /// [node]が違反かどうかを、型ベースの判定と本体ベースの判定を
  /// ORで組み合わせて判定する。
  bool _violatesBareFuture(MethodDeclaration node) {
    final returnType = _declaredReturnType(node);

    // 型ベースの判定: 宣言(要素)返り値型が「素のFuture(型引数がResultでない、
    // 型引数なし・dynamic含む、またはFuture自体がnullable)」または
    // 「FutureOr(型引数を問わず)」であれば違反。
    // FutureOrは型引数がResultであってもRepositoryのAPIとしては
    // `Future<Result<T>>`に統一したいため一律違反として扱う。
    if (returnType is InterfaceType) {
      if (returnType.isDartAsyncFutureOr) return true;
      if (returnType.isDartAsyncFuture) {
        return !_isConformingFutureOfResult(returnType);
      }
    }

    // 本体ベースの判定: 上記の型ベースの判定だけでは、返り値型が
    // `InterfaceType`の`Future`/`FutureOr`にならないケース
    // (`dynamic`明示、interfaceを持たず注釈も省略した実装で要素の返り値型が
    // `dynamic`になる場合、`void ... async {}`のfire-and-forget)を
    // 捕まえられない。`async`(generatorを除く)な本体は実行時に必ず
    // (素の)`Future`を返すため、ここまで到達した時点(=型ベースの判定で
    // 適合形と確認できなかった時点)でasyncな本体であれば違反として扱う。
    // async*/sync*のgeneratorはStreamを返すため対象外のまま
    // (Streamの扱いは今回のスコープ外)。
    return _isAsyncNonGeneratorBody(node.body);
  }

  bool _isAsyncNonGeneratorBody(FunctionBody body) {
    return body.isAsynchronous && !body.isGenerator;
  }

  /// [futureType](`Future<...>`)が「非nullableで、型引数がひとつだけあり、
  /// それが非nullableな`Result`である」という適合形かどうかを判定する。
  bool _isConformingFutureOfResult(InterfaceType futureType) {
    if (futureType.nullabilitySuffix != NullabilitySuffix.none) return false;
    return _isResultType(futureType);
  }

  /// [futureType]の型引数がひとつだけあり、それが非nullableな`Result`で
  /// あるかを判定する。`Result<T>?`のようにResult自体がnullableな場合は
  /// 違反として扱う(nullableなResultはOk/Errorという契約を壊すため、
  /// Repositoryの公開APIとして許容しない)。
  bool _isResultType(InterfaceType futureType) {
    if (futureType.typeArguments.length != 1) return false;
    final typeArgument = futureType.typeArguments.single;
    if (typeArgument is! InterfaceType) return false;
    if (typeArgument.nullabilitySuffix != NullabilitySuffix.none) {
      return false;
    }
    return isResultElement(typeArgument.element);
  }
}
