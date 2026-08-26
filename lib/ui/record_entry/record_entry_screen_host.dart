import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'record_entry_screen.dart';
import 'record_entry_view_model.dart';

/// [RecordEntryViewModel] を画面と同寿命で所有し、[RecordEntryScreen] へ注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直される。その結果、旧ViewModelのdispose(カテゴリ・資産の購読解除)と
/// 新ViewModelの生成(新しいノートのRepositoryの購読開始)が必ず対になる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
class RecordEntryScreenHost extends StatefulWidget {
  const RecordEntryScreenHost({super.key});

  @override
  State<RecordEntryScreenHost> createState() => _RecordEntryScreenHostState();
}

class _RecordEntryScreenHostState extends State<RecordEntryScreenHost> {
  late final RecordEntryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RecordEntryViewModel(
      recordRepository: context.read(),
      categoryRepository: context.read(),
      propertyRepository: context.read(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RecordEntryScreen(viewModel: _viewModel);
}
