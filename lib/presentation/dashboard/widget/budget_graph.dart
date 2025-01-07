import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/common/logic/formatter.dart';

class BudgetGraph extends StatelessWidget {
  final List<BudgetGraphData> _list;

  BudgetGraph({
    required List<BudgetGraphData> dataList,
    super.key,
  }) : _list = dataList;

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
          _PieChart(
            _SummarizedBudgetGraphDataList.from(
              _list,
            ),
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
}

/// [_SummarizedBudgetGraphDataList]の要素
class _SummarizedBudgetGraphData {
  /// [BudgetGraphData]からデータをまとめる
  _SummarizedBudgetGraphData.from(
    BudgetGraphData data,
    int totalBudget,
    Color this._color,
  )   : _name = data._name,
        _spent = data._spent,
        _ratio = calculateRatio(data._spent, totalBudget);

  /// その他用のコンストラクタ
  _SummarizedBudgetGraphData.etc({
    required int spent,
    required int totalBudget,
    required Color color,
  })  : _name = 'その他',
        _spent = spent,
        _ratio = calculateRatio(spent, totalBudget),
        _color = color;

  /// 表示名
  final String _name;

  /// 使用額
  final int _spent;

  /// 予算の合計に対する使用額の割合
  final int _ratio;

  /// グラフの色
  final Color _color;

  /// 凡例用のデータに変換する
  _LegendData _toLegendData() {
    return _LegendData(
      name: _name,
      spent: _spent,
      ratio: _ratio,
      color: _color,
    );
  }

  static int calculateRatio(int spent, int totalBudget) {
    return (spent / totalBudget * 100).round();
  }
}

/// グラフ表示用にまとめられたデータのリスト
class _SummarizedBudgetGraphDataList {
  _SummarizedBudgetGraphDataList.from(
    List<BudgetGraphData> dataList,
  )   : _totalBudget = dataList.fold(0, (sum, item) => sum + item._budget),
        _totalSpent = dataList.fold(0, (sum, item) => sum + item._spent),
        _isNotBudgetConfigured = dataList.isEmpty {
    final sortedSpentDataList = dataList.where((item) => item._isSpent).toList()
      ..sort((a, b) {
        final aRatio = a._spent / _totalBudget;
        final bRatio = b._spent / _totalBudget;
        return bRatio.compareTo(aRatio);
      });

    const notSummarizedDataCount = 3;
    for (int i = 0; i < notSummarizedDataCount; i++) {
      final graphData;
      try {
        graphData = sortedSpentDataList.elementAt(i);
      } catch (RangeError) {
        // 予算の設定が足りない場合は、ループを抜ける
        break;
      }
      const colors = [
        Color(0xFFFF0000),
        Color(0xFF005AFF),
        Color(0xFFFFF100),
      ];
      assert(colors.length == notSummarizedDataCount);
      _data.add(
        _SummarizedBudgetGraphData.from(
          graphData,
          _totalBudget,
          colors[i],
        ),
      );
    }
    if (sortedSpentDataList.length > notSummarizedDataCount) {
      final otherSpent = sortedSpentDataList
          .skip(notSummarizedDataCount)
          .fold(0, (sum, item) => sum + item._spent);
      _data.add(
        _SummarizedBudgetGraphData.etc(
          spent: otherSpent,
          totalBudget: _totalBudget,
          color: Color(0xFF4DC4FF),
        ),
      );
    }
  }

  final List<_SummarizedBudgetGraphData> _data = [];

  /// 合計予算
  final int _totalBudget;

  /// 合計使用額
  final int _totalSpent;

  /// 残高（合計予算から合計使用額を引いたもの）
  int get _balance => _totalBudget - _totalSpent;

  /// 残高がマイナスか
  bool get _isNegativeBalance => _balance < 0;

  /// 予算の設定が存在しない
  ///
  /// 予算が1つも設定されていない場合にtrueを返す。
  /// 「0円の予算があるか」ということではなく、予算の設定それ自体が存在しないかどうかを判定する。
  final bool _isNotBudgetConfigured;

  /// 予算を1円も使っていない
  bool get _isNotSpent => _totalSpent == 0;

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
            value: item._spent.toDouble(),
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
    required int ratio,
    required Color color,
  })  : _name = name,
        _spent = spent,
        _ratio = ratio,
        _color = color;

  /// 予算の名前
  final String _name;

  /// 予算の使用額
  final int _spent;

  /// 合計予算に対する使用額[_spent]の割合
  final int _ratio;

  /// グラフの色
  final Color _color;
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
          color: _data._color,
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
  const _PieChart(this._summarizedDataList);

  final _SummarizedBudgetGraphDataList _summarizedDataList;

  @override
  Widget build(BuildContext context) {
    final Widget legendContent;
    if (_summarizedDataList._isNotBudgetConfigured) {
      legendContent = const Text('予算が未設定です');
    } else if (_summarizedDataList._isNotSpent) {
      legendContent = const Text('予算を使っていません');
    } else {
      legendContent =
          _LegendArea(list: _summarizedDataList._toLegendDataList());
    }

    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.labelMedium,
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Graph(_summarizedDataList),
          legendContent,
        ],
      ),
    );
  }
}

class _Graph extends StatelessWidget {
  const _Graph(this._list);

  final _SummarizedBudgetGraphDataList _list;

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
          child: DefaultTextStyle.merge(
            // 残高がマイナスの場合は赤色にする
            style: DefaultTextStyle.of(context).style.apply(
                  color: _list._isNegativeBalance
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
            child: _TextAtCenterOfGraph(
              name: '残高',
              value: _list._balance,
            ),
          ),
        ),
      ],
    );
  }
}
