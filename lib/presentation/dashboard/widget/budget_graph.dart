import 'package:flutter/widgets.dart';

class BudgetGraph extends StatelessWidget {
  final List<BudgetGraphData> _data;

  const BudgetGraph({
    required List<BudgetGraphData> data,
    super.key,
  }) : _data = data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _data.map((item) => Text(item.name)).toList(),
    );
  }
}

class BudgetGraphData {
  final String name;
  final int spent;
  final int budget;

  const BudgetGraphData({
    required this.name,
    required this.spent,
    required this.budget,
  });
}
