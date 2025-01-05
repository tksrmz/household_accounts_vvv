import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/common/logic/formatter.dart';

class BudgetGraph extends StatelessWidget {
  final BudgetGraphDataList _list;

  const BudgetGraph({
    required BudgetGraphDataList list,
    super.key,
  }) : _list = list;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        textTheme: TextTheme.of(context),
      ),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(),
          Flexible(
            child: _PieChart(list: _list),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Text(
      '予算',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class BudgetGraphData {
  final String _name;
  final int _spent;
  final int _budget;

  const BudgetGraphData({
    required String name,
    required int spent,
    required int budget,
  })  : _name = name,
        _spent = spent,
        _budget = budget;

  /// 予算を使っているか
  bool get _isSpent => _spent > 0;

  _LegendData _toLegendData(int totalBudget) {
    return _LegendData(
      name: _name,
      spent: _spent,
      totalBudget: totalBudget,
    );
  }
}

class BudgetGraphDataList {
  final List<BudgetGraphData> _data;

  const BudgetGraphDataList({
    required List<BudgetGraphData> data,
  }) : _data = data;

  int get _totalBudget => _data.fold(0, (sum, item) => sum + item._budget);

  int get _totalSpent => _data.fold(0, (sum, item) => sum + item._spent);

  int get _balance => _totalBudget - _totalSpent;

  /// 予算の設定が存在しない
  ///
  /// 予算が1つも設定されていない場合にtrueを返す。
  /// 「0円の予算があるか」ということではなく、予算の設定それ自体が存在しないかどうかを判定する。
  bool get _isNotBudgetConfigured => _data.isEmpty;

  /// 予算を1円も使っていない
  bool get _isNotSpent => _totalSpent == 0;

  /// 予算を使っているデータのリストに変換する
  UnmodifiableListView<BudgetGraphData> get _spentDataList =>
      UnmodifiableListView(_data.where((item) => item._isSpent));

  List<_LegendData> _toLegendDataList() {
    return _spentDataList
        .map((item) => item._toLegendData(_totalBudget))
        .toList();
  }

  /// fl_chartのPieChartで表示するためのデータに変換する
  ///
  /// 予算を使っていない場合は、円グラフを表示するためにダミーの値を設定する。
  UnmodifiableListView<PieChartSectionData> _toPieChartSections({
    required Color emptySpaceColor,
    required radius,
  }) {
    final result = _spentDataList
        .map(
          (item) => PieChartSectionData(
            value: item._spent.toDouble(),
            color: Colors.red,
            radius: radius,
            showTitle: false,
          ),
        )
        .toList()
      ..add(
        PieChartSectionData(
          // グラフを表示するため、予算を使っていない場合はダミーの値を設定する
          value: _isNotBudgetConfigured ? 1 : _balance.toDouble(),
          color: emptySpaceColor,
          radius: radius,
          showTitle: false,
        ),
      );
    return UnmodifiableListView(result);
  }
}

class _LegendData {
  _LegendData({
    required String name,
    required int spent,
    required int totalBudget,
  })  : _name = name,
        _spent = spent,
        _ratio = (spent / totalBudget * 100).round();

  final String _name;
  final int _spent;
  final int _ratio;
}

class _Legend extends StatelessWidget {
  final _LegendData _data;

  const _Legend({
    required _LegendData data,
  }) : _data = data;

  @override
  Widget build(BuildContext context) {
    const double containerEdgeSize = 16;

    return Row(
      spacing: 8,
      children: [
        Container(
          width: containerEdgeSize,
          height: containerEdgeSize,
          color: Colors.red,
        ),
        Text(_data._name),
        Text(Formatter.simpleCurrency(_data._spent)),
        Text('(${_data._ratio}%)'),
      ],
    );
  }
}

class _LegendArea extends StatelessWidget {
  const _LegendArea({
    required List<_LegendData> list,
  }) : _list = list;

  final List<_LegendData> _list;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _list.map((item) => _Legend(data: item)).toList(),
    );
  }
}

class _TextAtCenterOfGraph extends StatelessWidget {
  const _TextAtCenterOfGraph({
    required String name,
    required int value,
  })  : _name = name,
        _value = value;

  final String _name;
  final int _value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_name),
        Text(
          Formatter.simpleCurrency(_value),
        ),
      ],
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({
    required BudgetGraphDataList list,
  }) : _list = list;

  final BudgetGraphDataList _list;

  @override
  Widget build(BuildContext context) {
    final Widget legendContent;
    if (_list._isNotBudgetConfigured) {
      legendContent = const Text('予算が未設定です');
    } else if (_list._isNotSpent) {
      legendContent = const Text('予算を使っていません');
    } else {
      legendContent = _LegendArea(list: _list._toLegendDataList());
    }

    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.labelMedium,
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Graph(list: _list),
          legendContent,
        ],
      ),
    );
  }
}

class _Graph extends StatelessWidget {
  const _Graph({
    required BudgetGraphDataList list,
  }) : _list = list;

  final BudgetGraphDataList _list;

  @override
  Widget build(BuildContext context) {
    const double radius = 100; // 円グラフの半径
    const double innerCircleRadius = radius * 0.65; // 円グラフの半径の65%
    const double centerTextAlignHeightFactor = 2.0 + 0.3; // childの高さの倍+アルファ

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.square(
          dimension: radius * 2,
          child: PieChart(
            PieChartData(
              sections: _list._toPieChartSections(
                emptySpaceColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                radius: radius - innerCircleRadius,
              ),
              centerSpaceRadius: innerCircleRadius,
              sectionsSpace: 0,
              startDegreeOffset: 270,
              pieTouchData: PieTouchData(
                enabled: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          heightFactor: centerTextAlignHeightFactor,
          child: _TextAtCenterOfGraph(
            name: '合計予算',
            value: _list._totalBudget,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          heightFactor: centerTextAlignHeightFactor,
          child: _TextAtCenterOfGraph(
            name: '残高',
            value: _list._balance,
          ),
        ),
      ],
    );
  }
}
