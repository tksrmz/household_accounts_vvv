import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';

import 'result_type.dart';
import 'target_path.dart';

/// Repository実装(`lib/data/repositories/`配下かつクラス/mixin名が`Repository`で
/// 終わる宣言)の規約を機械検証するルール。
///
/// 規約: 公開メソッドで宣言返り値型が`Future<Result<...>>`のものは、
/// 本体を`Result.guard(...)`の直接返しにする(try/catch手書き禁止)。
/// メソッドごとのcatch節の書き漏らし(`on FirebaseException`だけ書いて他の
/// Exceptionを取りこぼす等)を構造的に防ぐための規約であり、詳細な経緯は
/// `lib/utils/result.dart`の`Result.guard`のdocコメントを参照。
class RepositoryMustUseResultGuard extends AnalysisRule {
  RepositoryMustUseResultGuard()
    : super(
        name: ruleName,
        description:
            'Repository実装のFuture<Result>を返す公開メソッドは、'
            '本体をResult.guard(...)の直接返しにする。',
      );

  static const ruleName = 'repository_must_use_result_guard';

  // 既定のLintCodeはINFO重大度だが、この規約はCIで確実に検知したいため
  // ERROR重大度で報告する(analyzeの終了コードを違反の有無に連動させるため)。
  static const LintCode code = LintCode(
    ruleName,
    'Repository実装のFuture<Result>を返す公開メソッドは、本体をResult.guard(...)を'
    '直接返す形にする(try/catch手書き禁止)。',
    correctionMessage:
        "'=> Result.guard(() => ...)' または "
        "'{ return Result.guard(() => ...); }' に書き換えること。"
        '背景はlib/utils/result.dartのResult.guardのdocコメントを参照。',
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

  final RepositoryMustUseResultGuard rule;
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
    if (_directlyReturnsResultGuard(node.body)) {
      return;
    }
    rule.reportAtToken(node.name);
  }

  /// 検証対象: 公開("_"始まりでない)メソッドで、
  /// 宣言返り値型が`Future<Result<...>>`であるもの。
  /// 規約の関心は「Repositoryがどんな形のAPIを公開するか」なので、
  /// 判定基準は公開/非公開であり、staticか否かは問わない。
  /// getter/setter/operator・本体のない(抽象)メソッドは対象外。
  bool _isTargetMethod(MethodDeclaration node) {
    if (node.isGetter || node.isSetter || node.isOperator) return false;
    if (node.name.lexeme.startsWith('_')) return false;
    if (node.body is EmptyFunctionBody) return false;
    return _returnsFutureOfResult(_declaredReturnType(node));
  }

  /// [node]の「宣言要素」としての返り値型を返す。
  /// 構文上の`node.returnType?.type`ではなくこちらを使うのは、
  /// 返り値型の注釈を省略してinterfaceの型を継承するオーバーライド
  /// (`class FakeRepository implements BaseRepository { signOut() async {...} }`
  /// のような書き方)をすり抜けさせないため。注釈がある場合は同じ型が得られ、
  /// 注釈がなく継承元もない場合は自然に`dynamic`になり対象外になる。
  DartType? _declaredReturnType(MethodDeclaration node) {
    return node.declaredFragment?.element.returnType;
  }

  /// 宣言返り値型が`Future<Result<T>>`(Tは任意)かどうかを判定する。
  /// Future側は標準ライブラリの型なので解決済み型で判定し、Result側は
  /// アプリ固有の型で標準判定が存在しないため[isResultElement]で判定する。
  bool _returnsFutureOfResult(DartType? returnType) {
    if (returnType is! InterfaceType || !returnType.isDartAsyncFuture) {
      return false;
    }
    if (returnType.typeArguments.length != 1) return false;

    final resultTypeArgument = returnType.typeArguments.single;
    return resultTypeArgument is InterfaceType &&
        isResultElement(resultTypeArgument.element);
  }

  /// メソッド本体が式本体`=> Result.guard(...)`、またはブロック本体
  /// `{ return Result.guard(...); }`(単一のreturn文のみ)であるかを判定する。
  /// asyncキーワード付きや`await Result.guard(...)`はResultを直接返す形では
  /// ないため、対象外ではなく違反として扱う(falseを返す)。
  bool _directlyReturnsResultGuard(FunctionBody body) {
    if (body.keyword != null) return false;

    final returned = switch (body) {
      ExpressionFunctionBody(:final expression) => expression,
      BlockFunctionBody(:final block) when block.statements.length == 1 =>
        switch (block.statements.single) {
          ReturnStatement(:final expression) => expression,
          _ => null,
        },
      _ => null,
    };
    return returned != null && _isResultGuardInvocation(returned);
  }

  /// [expression]が`Result.guard(...)`の呼び出しであるかを判定する。
  /// 「メソッド名が`guard`で、ターゲットが`Result`というクラスへの参照」で判定する。
  /// ターゲットの要素解決ができる場合はクラス`Result`であることまで確認し、
  /// できない場合は識別子名(`Result`)のみの構文的な一致で判定する。
  bool _isResultGuardInvocation(Expression expression) {
    if (expression is! MethodInvocation) return false;
    if (expression.methodName.name != 'guard') return false;

    final target = expression.target;
    if (target is! SimpleIdentifier || target.name != 'Result') {
      return false;
    }

    final targetElement = target.element;
    if (targetElement is InterfaceElement) {
      return targetElement.name == 'Result';
    }
    return true;
  }
}
