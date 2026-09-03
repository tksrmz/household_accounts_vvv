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
  const CalendarScreenHost({super.key, this.now = DateTime.now});

  /// 現在日時の取得手段。本番は既定値のままでよく、テストが固定日時を
  /// 注入するための口である([CalendarViewModel.new]の`now`へそのまま渡す)。
  final DateTime Function() now;

  @override
  State<CalendarScreenHost> createState() => _CalendarScreenHostState();
}

class _CalendarScreenHostState extends State<CalendarScreenHost>
    with WidgetsBindingObserver {
  late final CalendarViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarViewModel(
      recordRepository: context.read(),
      now: widget.now,
    );
    // タブがIndexedStackに保持されたまま月をまたぐと、時間の経過だけでは
    // 再描画されず「翌月へ進む」ボタンが無効のまま残る。日時が進んでいそうな
    // 契機であるアプリ復帰を監視し、現在月の確認をViewModelへ委ねる
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.refreshCurrentMonth();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CalendarScreen(viewModel: _viewModel);
}
