import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

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
    if (!_violatesBareFuture(node.returnType?.type)) {
      return;
    }
    rule.reportAtToken(node.name);
  }

  /// 検証対象: 公開("_"始まりでない)メソッド。
  /// getter/setter/operatorは対象外(Repositoryの公開APIの形は
  /// `repository_no_public_properties`側の関心)。
  /// 本体の有無は問わない。抽象メソッド(interfaceの宣言)こそAPIの形
  /// そのものであり、実装だけでなく宣言時点で規約を検証する必要がある。
  bool _isTargetMethod(MethodDeclaration node) {
    if (node.isGetter || node.isSetter || node.isOperator) return false;
    if (node.name.lexeme.startsWith('_')) return false;
    return true;
  }

  /// 宣言返り値型が「素のFuture(型引数がResultでない、型引数なし・dynamic含む)」
  /// または「FutureOr(型引数を問わず)」であるとき、違反とみなす。
  /// FutureOrは型引数がResultであってもRepositoryのAPIとしては
  /// `Future<Result<T>>`に統一したいため一律違反として扱う。
  bool _violatesBareFuture(DartType? returnType) {
    if (returnType is! InterfaceType) return false;

    if (returnType.isDartAsyncFutureOr) return true;

    if (returnType.isDartAsyncFuture) {
      return !_isResultType(returnType);
    }

    return false;
  }

  /// [futureType]の型引数がひとつだけあり、それが`Result`であるかを判定する。
  /// Result側はアプリ固有の型で標準判定が存在しないため要素名で判定する
  /// (`repository_must_use_result_guard`と同じ方針)。
  bool _isResultType(InterfaceType futureType) {
    if (futureType.typeArguments.length != 1) return false;
    final typeArgument = futureType.typeArguments.single;
    return typeArgument is InterfaceType &&
        typeArgument.element.name == 'Result';
  }
}
