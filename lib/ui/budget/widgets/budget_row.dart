import 'package:flutter/material.dart';

import '../../../common/logic/formatter.dart';

/// 支出カテゴリ1件の予算の消化状況を表す行。名前と「支出 / 予算」の金額、
/// その下に消化の割合を示すバーを並べる。
class BudgetRow extends StatelessWidget {
  const BudgetRow({
    super.key,
    required this.name,
    required this.spent,
    required this.budget,
  });

  /// 行に表示するカテゴリ名。
  final String name;

  /// 期間中の支出額(0以上)。
  final int spent;

  /// 予算額(0以上)。
  final int budget;

  /// バーを塗る割合(0.0〜1.0)。
  ///
  /// 予算を超えた分はバーの外へはみ出させず、満タンで頭打ちにする。予算が0の
  /// ときは割合を計算できない(0で割る)ため、支出があれば満タン(予算を
  /// 使い切っている)、無ければ空とする。
  static double fillRatio({required int spent, required int budget}) {
    if (budget == 0) {
      return spent > 0 ? 1.0 : 0.0;
    }
    return (spent / budget).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // 名前が長くても金額を画面外へ押し出さないよう、残りの幅に収めて
            // 折り返す
            Expanded(child: Text(name)),
            const SizedBox(width: 8),
            Text(
              '${Formatter.simpleCurrency(spent)} / '
              '${Formatter.simpleCurrency(budget)}',
            ),
          ],
        ),
        SizedBox(
          height: 20,
          width: double.infinity,
          child: ColoredBox(
            color: Colors.grey,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillRatio(spent: spent, budget: budget),
              child: ColoredBox(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
