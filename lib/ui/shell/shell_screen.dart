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
class ShellScreen extends StatelessWidget {
  const ShellScreen({
    required this.navigationShell,
    required this.viewModel,
    super.key,
  });

  /// go_routerが提供するタブのナビゲーションシェル。
  final StatefulNavigationShell navigationShell;

  /// シェルと同寿命で[ShellScreenHost]から注入されるViewModel。
  final ShellViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return switch (viewModel.pairState) {
          ShellPairLoading() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          ShellPairError(:final error) => Scaffold(
            body: Center(child: Text(error.toString())),
          ),
          ShellPairData() => Provider<UserInfo>.value(
            // 読み手はもういないが、ShellViewModelのペア判定がUserInfo型を使って
            // いるため、その置き換えと一緒に後続の後始末で除去する
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
      },
    );
  }
}
