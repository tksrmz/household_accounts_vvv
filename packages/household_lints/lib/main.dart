import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/repository_must_use_result_guard.dart';
import 'src/rules/repository_no_bare_future.dart';
import 'src/rules/repository_no_public_properties.dart';

// Analysis Serverはこのファイルをsyntheticにimportし、トップレベル変数`plugin`を
// 参照してプラグインを読み込む(変数名は固定の規約)。
final plugin = HouseholdLintsPlugin();

/// household_accountsのプロジェクト固有規約を検証するanalyzer plugin。
class HouseholdLintsPlugin extends Plugin {
  @override
  String get name => 'household_lints';

  @override
  void register(PluginRegistry registry) {
    // 既定で有効にはせず、consumer側のanalysis_options.yamlで明示的に
    // 有効化させるためregisterLintRuleを使う(registerWarningRuleは既定で有効)。
    registry.registerLintRule(RepositoryMustUseResultGuard());
    registry.registerLintRule(RepositoryNoBareFuture());
    registry.registerLintRule(RepositoryNoPublicProperties());
  }
}
