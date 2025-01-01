import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:household_accounts/common/logic/formatter.dart';

class BudgetGraph extends StatelessWidget {
  final BudgetGraphDataList _list;

  const BudgetGraph({
    required BudgetGraphDataList list,
    super.key,
  }) : _list = list;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // FIXME: Remove Expanded widget when the design is fixed
        Expanded(
          child: Row(
            children: [
              const Text('合計予算'),
              Expanded(
                child: Text(
                  Formatter.simpleCurrency(_list._totalBudget),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: _list._data.map((item) => _Legend(data: item)).toList(),
        )
      ],
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
}

class BudgetGraphDataList {
  final List<BudgetGraphData> _data;

  const BudgetGraphDataList({
    required List<BudgetGraphData> data,
  }) : _data = data;

  int get _totalBudget => _data.fold(0, (sum, item) => sum + item._budget);
}

class _Legend extends StatelessWidget {
  final BudgetGraphData _data;

  const _Legend({
    required BudgetGraphData data,
  }) : _data = data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_data._name),
        Text(Formatter.simpleCurrency(_data._spent)),
      ],
    );
  }
}
