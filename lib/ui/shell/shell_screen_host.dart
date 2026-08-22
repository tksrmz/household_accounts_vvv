import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/profile/profile_repository.dart';
import 'shell_screen.dart';
import 'shell_view_model.dart';

/// [ShellViewModel] をシェルと同寿命で所有し、[ShellScreen] へ注入するホスト。
///
/// StatefulShellRoute.builderはタブ切替のたびに再実行されるため、builder内で
/// 直接VMを生成すると切替ごとにペア検知が再購読されスピナーが点滅する。
/// このWidgetがStatefulWidgetとしてVMを保持することで、initStateで1回だけ
/// 生成しdisposeで確実に破棄する(ViewModelをProviderに登録しない規約
/// — Providerはリポジトリ・共有状態向け、画面のViewModelはコンストラクタ
/// 注入という規約 — を保つため、ChangeNotifierProviderではなくこの
/// StatefulWidgetでライフサイクルを持つ)。
class ShellScreenHost extends StatefulWidget {
  const ShellScreenHost({required this.navigationShell, super.key});

  /// go_routerが提供するタブのナビゲーションシェル。
  final StatefulNavigationShell navigationShell;

  @override
  State<ShellScreenHost> createState() => _ShellScreenHostState();
}

class _ShellScreenHostState extends State<ShellScreenHost> {
  late final ShellViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ShellViewModel(
      authRepository: context.read(),
      selectedNoteState: context.read(),
      watchPairStatus: (uid) =>
          context.read<ProfileRepository>().watchPairStatus(uid),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShellScreen(
    navigationShell: widget.navigationShell,
    viewModel: _viewModel,
  );
}
