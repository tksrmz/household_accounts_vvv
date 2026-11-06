import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'properties_screen.dart';
import 'properties_view_model.dart';

/// [PropertiesViewModel] を画面と同寿命で所有し、[PropertiesScreen] へ注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直される。その結果、旧ViewModelのdispose(資産の購読解除)と
/// 新ViewModelの生成(新しいノートのRepositoryの購読開始)が必ず対になる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
class PropertiesScreenHost extends StatefulWidget {
  const PropertiesScreenHost({super.key});

  @override
  State<PropertiesScreenHost> createState() => _PropertiesScreenHostState();
}

class _PropertiesScreenHostState extends State<PropertiesScreenHost> {
  late final PropertiesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PropertiesViewModel(propertyRepository: context.read());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PropertiesScreen(viewModel: _viewModel);
}
