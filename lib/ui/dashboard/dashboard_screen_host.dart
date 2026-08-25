import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/notebook.dart';
import '../../domain/models/period.dart';
import 'dashboard_screen.dart';
import 'dashboard_view_model.dart';

/// [DashboardViewModel] を画面と同寿命で所有し、[DashboardScreen] へ注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直される。その結果、旧ViewModelのdispose(レコード購読の解除)と
/// 新ViewModelの生成(新しいノートのRepositoryの購読開始)が必ず対になる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
class DashboardScreenHost extends StatefulWidget {
  const DashboardScreenHost({super.key, required this.notebook});

  /// 表示対象のノート(個人 / 共有)。
  final Notebook notebook;

  @override
  State<DashboardScreenHost> createState() => _DashboardScreenHostState();
}

class _DashboardScreenHostState extends State<DashboardScreenHost> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewModel = DashboardViewModel(
      recordRepository: context.read(),
      profileRepository: context.read(),
      authRepository: context.read(),
      notebook: widget.notebook,
      period: Period.calendarMonth(now.year, now.month),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DashboardScreen(viewModel: _viewModel);
}
