import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/common/logic/formatter.dart';

import '../../../../../presentation/dashboard/model/budget_graph_data.dart';
import '../../../../../presentation/dashboard/model/budget_graph_data_list.dart';
import '../../../../../presentation/dashboard/vo/budget_name.dart';
import '../../../../../vo/budget_amount.dart';
import '../../../../../vo/budget_spent.dart';

class BudgetGraph extends StatelessWidget {
  final BudgetGraphDataList _list;

  BudgetGraph({
    required BudgetGraphDataList list,
    super.key,
  }) : _list = list;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        // テストで特定のフォントを使うため、textThemeの設定が必要
        textTheme: TextTheme.of(context),
      ),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(),
          _PlotArea(_list),
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
      style: TextTheme.of(context).titleMedium,
    );
  }
}

/// [_BudgetGraphDataListForPlot]の要素
class _BudgetGraphDataForPlot {
  /// [BudgetGraphData]からデータをまとめる
  _BudgetGraphDataForPlot.from(
    BudgetGraphData data,
    Color this._color,
  )   : _name = data.name,
        _spent = data.spent;

  /// その他用のコンストラクタ
  _BudgetGraphDataForPlot.etc(BudgetSpent spent)
      : _name = BudgetName('その他'),
        _spent = spent,
        _color = Color(0xFF4DC4FF);

  /// 表示名
  final BudgetName _name;

  /// 使用額
  final BudgetSpent _spent;

  /// グラフの色
  final Color _color;

  /// 凡例用のデータに変換する
  _LegendData _toLegendData() {
    return _LegendData(
      name: _name.value,
      spent: _spent.value,
      color: _color,
    );
  }
}

/// グラフ表示用にまとめられたデータのリスト
class _BudgetGraphDataListForPlot {
  _BudgetGraphDataListForPlot.from(BudgetGraphDataList list)
      : _data = [],
        _totalBudget = list.totalBudget,
        _isNotBudgetConfigured = list.isNotBudgetConfigured {
    const colors = [
      Color(0xFFFF0000),
      Color(0xFF005AFF),
      Color(0xFFFFF100),
    ];
    final savedDataCount = colors.length;

    final source = list.sortBySpentRatio().toListWhereBudgetIsSpent();

    var index = 0;
    source.list.take(savedDataCount).forEach((item) {
      _data.add(
        _BudgetGraphDataForPlot.from(
          item,
          colors[index++],
        ),
      );
    });

    final toBeSummarized =
        BudgetGraphDataList(source.list.skip(savedDataCount).toList());
    if (toBeSummarized.isBudgetConfigured) {
      _data.add(
        _BudgetGraphDataForPlot.etc(
          BudgetSpent.sum(toBeSummarized.toBudgetSpentList()),
        ),
      );
    }
  }

  final List<_BudgetGraphDataForPlot> _data;

  /// 合計予算
  final BudgetAmount _totalBudget;

  /// 合計使用額
  BudgetSpent get _totalSpent => BudgetSpent.sum(
        _data.map((item) => item._spent).toList(),
      );

  /// 残高（合計予算から合計使用額を引いたもの）
  int get _balance => _totalBudget.value - _totalSpent.value;

  /// 残高がマイナスか
  bool get _isNegativeBalance => _balance < 0;

  /// 予算の設定が存在しない
  ///
  /// 予算が1つも設定されていない場合にtrueを返す。
  /// 「0円の予算があるか」ということではなく、予算の設定それ自体が存在しないかどうかを判定する。
  final bool _isNotBudgetConfigured;

  /// 予算を1円も使っていない
  bool get _isNotSpent => _totalSpent.isNotUsed;

  /// 凡例用のリストに変換する
  UnmodifiableListView<_LegendData> _toLegendDataList() {
    return UnmodifiableListView(
      _data.map(
        (item) => item._toLegendData(),
      ),
    );
  }

  /// fl_chartのPieChartで表示するためのデータに変換する
  ///
  /// 予算を使っていない場合は、円グラフを表示するためにダミーの値を設定する。
  UnmodifiableListView<PieChartSectionData> _toPieChartSections({
    required Color emptySpaceColor,
    required radius,
  }) {
    // グラフを表示するため、未使用のセクションにダミーの値を設定する
    // 予算が設定されていない場合のダミー
    const double dummyValue = 1;
    // 残高がマイナスの場合のダミー
    const double alternativeValueForNegativeBalance = 0;
    final double emptySectionValue = _isNotBudgetConfigured
        ? dummyValue
        : max(alternativeValueForNegativeBalance, _balance.toDouble());

    final result = _data
        .map(
          (item) => PieChartSectionData(
            value: item._spent.toDouble,
            color: item._color,
            radius: radius,
            showTitle: false,
          ),
        )
        .toList()
      ..add(
        PieChartSectionData(
          value: emptySectionValue,
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
    required Color color,
  })  : _name = name,
        _spent = spent,
        _color = color;

  /// 予算の名前
  final String _name;

  /// 予算の使用額
  final int _spent;

  /// グラフの色
  final Color _color;
}

class _Legend extends StatelessWidget {
  final _LegendData _data;

  const _Legend(this._data);

  @override
  Widget build(BuildContext context) {
    const double containerEdgeSize = 16;

    return Row(
      spacing: 8,
      children: [
        Container(
          width: containerEdgeSize,
          height: containerEdgeSize,
          color: _data._color,
        ),
        // 予算名が長い場合は省略する
        Flexible(
          child: Text(
            _data._name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          Formatter.simpleCurrency(_data._spent),
        ),
      ],
    );
  }
}

class _LegendArea extends StatelessWidget {
  const _LegendArea(this._list);

  final List<_LegendData> _list;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: _list.map((item) => _Legend(item)).toList(),
    );
  }
}

class _TextAtCenterOfGraph extends StatelessWidget {
  const _TextAtCenterOfGraph({
    required String name,
    required int value,
    TextStyle? style,
  })  : _name = name,
        _value = value,
        _style = style;

  final String _name;
  final int _value;
  final TextStyle? _style;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _name,
          style: _style,
        ),
        Text(
          Formatter.simpleCurrency(_value),
          style: _style,
        ),
      ],
    );
  }
}

class _PlotArea extends StatelessWidget {
  _PlotArea(BudgetGraphDataList list)
      : _listForPlot = _BudgetGraphDataListForPlot.from(list);

  final _BudgetGraphDataListForPlot _listForPlot;

  @override
  Widget build(BuildContext context) {
    final Widget legendArea;
    if (_listForPlot._isNotBudgetConfigured) {
      legendArea = const Text('予算が未設定です');
    } else if (_listForPlot._isNotSpent) {
      legendArea = const Text('予算を使っていません');
    } else {
      legendArea = _LegendArea(_listForPlot._toLegendDataList());
    }

    return DefaultTextStyle.merge(
      style: TextTheme.of(context).labelMedium,
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GraphArea(_listForPlot),
          legendArea,
        ],
      ),
    );
  }
}

class _GraphArea extends StatelessWidget {
  const _GraphArea(this._list);

  final _BudgetGraphDataListForPlot _list;

  @override
  Widget build(BuildContext context) {
    const double centerTextAlignHeightFactor = 2.0 + 0.3; // childの高さの倍+アルファ

    return Stack(
      alignment: Alignment.center,
      children: [
        _PieChart(_list),
        Align(
          alignment: Alignment.topCenter,
          heightFactor: centerTextAlignHeightFactor,
          child: _TextAtCenterOfGraph(
            name: '総予算',
            value: _list._totalBudget.value,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          heightFactor: centerTextAlignHeightFactor,
          child: _TextAtCenterOfGraph(
            name: '残高',
            value: _list._balance,
            // 残高がマイナスの場合は赤色にする
            style: TextStyle(
              color: _list._isNegativeBalance
                  ? ColorScheme.of(context).error
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart(this._list);

  final _BudgetGraphDataListForPlot _list;

  @override
  Widget build(BuildContext context) {
    const double radius = 100; // 円グラフの半径
    const double innerCircleRadius = radius * 0.65; // 円グラフの半径の65%

    return SizedBox.square(
      dimension: radius * 2,
      child: PieChart(
        PieChartData(
          sections: _list._toPieChartSections(
            emptySpaceColor: ColorScheme.of(context).surfaceContainerHighest,
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
    );
  }
}
