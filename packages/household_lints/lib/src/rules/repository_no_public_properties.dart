import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import 'target_path.dart';

/// Repository実装(`lib/data/repositories/`配下かつクラス/mixin名が`Repository`で
/// 終わる宣言)の公開APIをメソッドのみに限定するルール。
///
/// 規約: 公開のgetter/setter/フィールドはRepositoryの外へ状態を直接漏出させる
/// 経路になり、かつ`repository_no_bare_future`のようなメソッド向けの規約検査の
/// 対象からも外れてしまう(例: 素のTを返すgetterで規約を迂回できる)ため、
/// Repositoryが公開するAPIはメソッドのみに統一する。
class RepositoryNoPublicProperties extends AnalysisRule {
  RepositoryNoPublicProperties()
    : super(
        name: ruleName,
        description:
            'Repositoryが公開するAPIはメソッドのみにする'
            '(公開getter/setter/フィールド禁止)。',
      );

  static const ruleName = 'repository_no_public_properties';

  // 既定のLintCodeはINFO重大度だが、この規約はCIで確実に検知したいため
  // ERROR重大度で報告する(analyzeの終了コードを違反の有無に連動させるため)。
  static const LintCode code = LintCode(
    ruleName,
    'Repositoryが公開するAPIはメソッドのみにする'
    '(公開getter/setter/フィールドは状態の漏出経路になり、規約検査の対象からも外れるため)。',
    correctionMessage: 'メソッドに変えるか、privateにすること。',
    severity: DiagnosticSeverity.ERROR,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this, context);
    registry.addMethodDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final RepositoryNoPublicProperties rule;
  final RuleContext context;

  /// getter/setter(`MethodDeclaration`として表現される)を検証する。
  /// 本体の有無は問わない(抽象interfaceのgetter/setter宣言も対象)。
  /// 通常のメソッド・operatorはここでは対象外
  /// (メソッドの返り値の形は`repository_no_bare_future`側の関心)。
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (!node.isGetter && !node.isSetter) return;
    if (node.name.lexeme.startsWith('_')) return;

    final path = context.currentUnit?.file.path;
    if (!isRepositoryApiDeclaration(node, path)) return;

    rule.reportAtToken(node.name);
  }

  /// フィールド宣言を検証する。instance/static、final/const/varを問わず、
  /// 公開("_"始まりでない)フィールドはすべて違反とする。
  /// ひとつの宣言に複数の変数(`int a, b;`)が含まれる場合は各々報告する。
  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final path = context.currentUnit?.file.path;
    if (!isRepositoryApiDeclaration(node, path)) return;

    for (final variable in node.fields.variables) {
      if (variable.name.lexeme.startsWith('_')) continue;
      rule.reportAtToken(variable.name);
    }
  }
}
