import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'categories_screen.dart';
import 'categories_view_model.dart';

/// [CategoriesViewModel] を画面と同寿命で所有し、[CategoriesScreen] へ注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直される。その結果、旧ViewModelのdispose(カテゴリの購読解除)と
/// 新ViewModelの生成(新しいノートのRepositoryの購読開始)が必ず対になる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
class CategoriesScreenHost extends StatefulWidget {
  const CategoriesScreenHost({super.key});

  @override
  State<CategoriesScreenHost> createState() => _CategoriesScreenHostState();
}

class _CategoriesScreenHostState extends State<CategoriesScreenHost> {
  late final CategoriesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CategoriesViewModel(categoryRepository: context.read());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CategoriesScreen(viewModel: _viewModel);
}
