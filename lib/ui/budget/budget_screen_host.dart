import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'budget_screen.dart';
import 'budget_view_model.dart';

/// [BudgetViewModel] を画面と同寿命で所有し、[BudgetScreen] へ注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直される。その結果、旧ViewModelのdispose(カテゴリとレコードの
/// 購読解除)と新ViewModelの生成(新しいノートのRepositoryの購読開始)が必ず
/// 対になる。ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態
/// 向け、画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProvider
/// ではなくこのStatefulWidgetでライフサイクルを持つ。
class BudgetScreenHost extends StatefulWidget {
  const BudgetScreenHost({super.key, this.now = DateTime.now});

  /// 現在日時の取得手段。本番は既定値のままでよく、テストが固定日時を
  /// 注入するための口である([BudgetViewModel.new]の`now`へそのまま渡す)。
  final DateTime Function() now;

  @override
  State<BudgetScreenHost> createState() => _BudgetScreenHostState();
}

class _BudgetScreenHostState extends State<BudgetScreenHost>
    with WidgetsBindingObserver {
  late final BudgetViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BudgetViewModel(
      recordRepository: context.read(),
      categoryRepository: context.read(),
      now: widget.now,
    );
    // タブがIndexedStackに保持されたまま期間をまたぐと、時間の経過だけでは
    // 再描画されず「次の期間へ進む」ボタンが無効のまま残る。日時が進んでいそうな
    // 契機であるアプリ復帰を監視し、今日の確認をViewModelへ委ねる
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.refreshToday();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BudgetScreen(viewModel: _viewModel);
}
