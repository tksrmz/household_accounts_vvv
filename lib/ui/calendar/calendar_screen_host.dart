import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'calendar_screen.dart';
import 'calendar_view_model.dart';

/// [CalendarViewModel] を画面と同寿命で所有し、[CalendarScreen] へ注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直される。その結果、旧ViewModelのdispose(レコード購読の解除)と
/// 新ViewModelの生成(新しいノートのRepositoryの購読開始)が必ず対になる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
class CalendarScreenHost extends StatefulWidget {
  const CalendarScreenHost({super.key});

  @override
  State<CalendarScreenHost> createState() => _CalendarScreenHostState();
}

class _CalendarScreenHostState extends State<CalendarScreenHost> {
  late final CalendarViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewModel = CalendarViewModel(
      recordRepository: context.read(),
      currentYear: now.year,
      currentMonth: now.month,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CalendarScreen(viewModel: _viewModel);
}
