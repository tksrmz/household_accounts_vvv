import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/property.dart';
import 'property_editor_screen.dart';
import 'property_editor_view_model.dart';

/// [PropertyEditorViewModel] を画面と同寿命で所有し、[PropertyEditorScreen] へ
/// 注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直され、新しいノートのRepositoryを持つViewModelに置き換わる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
class PropertyEditorScreenHost extends StatefulWidget {
  /// [property]を渡すとその資産の編集、省略すると資産の追加になる。
  const PropertyEditorScreenHost({super.key, Property? property})
    : _property = property;

  final Property? _property;

  @override
  State<PropertyEditorScreenHost> createState() =>
      _PropertyEditorScreenHostState();
}

class _PropertyEditorScreenHostState extends State<PropertyEditorScreenHost> {
  late final PropertyEditorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PropertyEditorViewModel(
      propertyRepository: context.read(),
      property: widget._property,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      PropertyEditorScreen(viewModel: _viewModel);
}
