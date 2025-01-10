import 'dart:collection';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/common/logic/formatter.dart';

import '../vo/budget_name.dart';
import '../vo/budget_spent.dart';

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
          _PlotArea(
            _SummarizedBudgetGraphDataList.from(_list),
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
      style: TextTheme.of(context).titleMedium,
    );
  }
}

class BudgetGraphData {
  final BudgetName _name;
  final BudgetSpent _spent;
  final int _budget;

  const BudgetGraphData({
    required BudgetName name,
    required BudgetSpent spent,
    required int budget,
  })  : _name = name,
        _spent = spent,
        _budget = budget;

  /// 予算を使っているか
  bool get _isSpent => _spent.isUsed;
}

class BudgetGraphDataList {
  final List<BudgetGraphData> _list;

  const BudgetGraphDataList(this._list);

  /// 予算の設定が存在しない
  ///
  /// 予算が1つも設定されていない場合にtrueを返す。
  /// 「0円の予算があるか」ということではなく、予算の設定それ自体が存在しないかどうかを判定する。
  bool get _isNotBudgetConfigured => _list.isEmpty;

  /// 予算の合計値を取得する
  int get _totalBudget => _list.fold(0, (sum, item) => sum + item._budget);

  /// 使用している予算だけを抜き出したリストへ変換する
  /// リストは総予算に対する使用額の割合の降順でソートされる
  BudgetGraphDataList _toSortedSpentBudgetList() {
    return BudgetGraphDataList(
      _list.where((item) => item._isSpent).toList()
        ..sort((a, b) {
          final aRatio = a._spent.value / _totalBudget;
          final bRatio = b._spent.value / _totalBudget;
          return bRatio.compareTo(aRatio);
        }),
    );
  }

  /// 予算の使用額のリストへ変換する
  UnmodifiableListView<BudgetSpent> _toBudgetSpentList() {
    return UnmodifiableListView(_list.map((item) => item._spent).toList());
  }

  /// 使用額の多い順にまとめたデータを取得する
  /// [savedElementCount]で保存する要素数を指定する
  /// 保存する要素数よりも多い場合は、その他の使用額をまとめたデータを追加する
  ///
  /// 返されるリストの要素数は最大で`savedElementCount + 1`となる
  BudgetGraphDataList _summarize(int savedElementCount) {
    final sortedSpentDataList = _toSortedSpentBudgetList();
    final result = sortedSpentDataList._list.take(savedElementCount).toList();
    final spentValues = BudgetGraphDataList(
      sortedSpentDataList._list.skip(savedElementCount).toList(),
    )._toBudgetSpentList();
    if (spentValues.isNotEmpty) {
      result.add(
        BudgetGraphData(
          name: BudgetName('その他'),
          spent: BudgetSpent.sum(spentValues),
          budget: _list.map((item) => item._budget).fold(0, (a, b) => a + b),
        ),
      );
    }
    return BudgetGraphDataList(result);
  }

  void _forEachIndexed(void Function(int index, BudgetGraphData data) f) {
    for (int i = 0; i < _list.length; i++) {
      f(i, _list[i]);
    }
  }
}

/// [_SummarizedBudgetGraphDataList]の要素
class _SummarizedBudgetGraphData {
  /// [BudgetGraphData]からデータをまとめる
  _SummarizedBudgetGraphData.from(
    BudgetGraphData data,
    Color this._color,
  )   : _name = data._name,
        _spent = data._spent;

  /// その他用のコンストラクタ
  _SummarizedBudgetGraphData.etc(BudgetSpent spent)
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
class _SummarizedBudgetGraphDataList {
  _SummarizedBudgetGraphDataList.from(BudgetGraphDataList list)
      : _totalBudget = list._totalBudget,
        _totalSpent = BudgetSpent.sum(list._toBudgetSpentList()),
        _isNotBudgetConfigured = list._isNotBudgetConfigured {
    const colors = [
      Color(0xFFFF0000),
      Color(0xFF005AFF),
      Color(0xFFFFF100),
    ];
    final savedDataCount = colors.length;
    list._summarize(savedDataCount)._forEachIndexed((index, data) {
      if (index < savedDataCount) {
        _data.add(
          _SummarizedBudgetGraphData.from(
            data,
            colors[index],
          ),
        );
      } else {
        _data.add(
          _SummarizedBudgetGraphData.etc(data._spent),
        );
      }
    });
  }

  final List<_SummarizedBudgetGraphData> _data = [];

  /// 合計予算
  final int _totalBudget;

  /// 合計使用額
  final BudgetSpent _totalSpent;

  /// 残高（合計予算から合計使用額を引いたもの）
  int get _balance => _totalBudget - _totalSpent.value;

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
        Text(_data._name),
        Text(Formatter.simpleCurrency(_data._spent)),
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
  const _PlotArea(this._summarizedDataList);

  final _SummarizedBudgetGraphDataList _summarizedDataList;

  @override
  Widget build(BuildContext context) {
    final Widget legendArea;
    if (_summarizedDataList._isNotBudgetConfigured) {
      legendArea = const Text('予算が未設定です');
    } else if (_summarizedDataList._isNotSpent) {
      legendArea = const Text('予算を使っていません');
    } else {
      legendArea = _LegendArea(_summarizedDataList._toLegendDataList());
    }

    return DefaultTextStyle.merge(
      style: TextTheme.of(context).labelMedium,
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GraphArea(_summarizedDataList),
          legendArea,
        ],
      ),
    );
  }
}

class _GraphArea extends StatelessWidget {
  const _GraphArea(this._list);

  final _SummarizedBudgetGraphDataList _list;

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
            value: _list._totalBudget,
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

  final _SummarizedBudgetGraphDataList _list;

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
