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

  List<_LegendData> _toLegendDataList() {
    return _data.map((item) => item._toLegendData(_totalBudget)).toList();
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
    return Column(
      children: [
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
    return Row(
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
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.labelMedium,
      child: Row(
        children: [
          _Graph(list: _list),
          _list._isNotBudgetConfigured
              ? const Text('予算が未設定です')
              : _LegendArea(list: _list._toLegendDataList()),
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
    const double diameter = radius * 2;
    const double sameWidthFactor = 1.0; // childと同じ幅の比率
    const double twiceHeightFactor = 2.0; // childの高さの倍

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          widthFactor: sameWidthFactor,
          heightFactor: twiceHeightFactor,
          child: _TextAtCenterOfGraph(
            name: '合計予算',
            value: _list._totalBudget,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          widthFactor: sameWidthFactor,
          heightFactor: twiceHeightFactor,
          child: _TextAtCenterOfGraph(
            name: '残高',
            value: _list._balance,
          ),
        ),
      ],
    );
  }
}
