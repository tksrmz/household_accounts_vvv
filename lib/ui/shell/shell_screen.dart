import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/util/model/user_info.dart';
import '../../routing/routes.dart';
import 'shell_scaffold.dart';
import 'shell_view_model.dart';

/// タブシェルのルート層Widget。
///
/// ペア検知の完了までローディングを表示し、完了後にシェル本体を描画する
/// (旧実装のペア検知ゲートを再現したもの)。
class ShellScreen extends StatelessWidget {
  const ShellScreen({required this.navigationShell, super.key});

  /// go_routerが提供するタブのナビゲーションシェル。
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ShellViewModel>();

    return switch (viewModel.pairState) {
      ShellPairLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      ShellPairError(:final error) => Scaffold(
        body: Center(child: Text(error.toString())),
      ),
      ShellPairData() => Provider<UserInfo>.value(
        // 旧タブページ群がProviderからUserInfoを読む互換供給。PR9で除去する
        value: viewModel.userInfo!,
        child: ShellScaffold(
          currentIndex: navigationShell.currentIndex,
          onSelectTab: navigationShell.goBranch,
          onOpenSettings: () => context.push(Routes.settings),
          viewModel: viewModel,
          body: navigationShell,
        ),
      ),
    };
  }
}
