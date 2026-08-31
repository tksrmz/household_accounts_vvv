import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'daily_records_screen.dart';
import 'daily_records_view_model.dart';

/// [DailyRecordsViewModel] を画面と同寿命で所有し、[DailyRecordsScreen] へ
/// 注入するホスト。
///
/// ノート切替時はrouterが `ValueKey(notebook)` を変えるため、このWidgetの
/// Stateごと作り直される。その結果、旧ViewModelのdispose(購読の解除)と
/// 新ViewModelの生成(新しいノートのRepositoryの購読開始)が必ず対になる。
/// ViewModelをProviderに登録しない規約(Providerはリポジトリ・共有状態向け、
/// 画面のViewModelはコンストラクタ注入)を保つため、ChangeNotifierProviderでは
/// なくこのStatefulWidgetでライフサイクルを持つ。
class DailyRecordsScreenHost extends StatefulWidget {
  const DailyRecordsScreenHost({
    super.key,
    required int year,
    required int month,
    required int day,
  }) : _year = year,
       _month = month,
       _day = day;

  final int _year;
  final int _month;
  final int _day;

  @override
  State<DailyRecordsScreenHost> createState() => _DailyRecordsScreenHostState();
}

class _DailyRecordsScreenHostState extends State<DailyRecordsScreenHost> {
  late final DailyRecordsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DailyRecordsViewModel(
      recordRepository: context.read(),
      categoryRepository: context.read(),
      propertyRepository: context.read(),
      year: widget._year,
      month: widget._month,
      day: widget._day,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      DailyRecordsScreen(viewModel: _viewModel);
}
