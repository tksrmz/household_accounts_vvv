import 'package:flutter/material.dart';

/// 表示中の年月と、前後の月へ移動する矢印を並べたヘッダ。
class MonthHeader extends StatelessWidget {
  const MonthHeader({
    super.key,
    required this.year,
    required this.month,
    required this.onPreviousMonthPressed,
    required this.onNextMonthPressed,
  });

  /// 表示中の年。
  final int year;

  /// 表示中の月(1〜12)。
  final int month;

  /// 前の月へ移動する操作。`null`のとき矢印は押下不可になる。
  final VoidCallback? onPreviousMonthPressed;

  /// 次の月へ移動する操作。`null`のとき矢印は押下不可になる。
  final VoidCallback? onNextMonthPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: onPreviousMonthPressed,
        ),
        Text('$year/$month'),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: onNextMonthPressed,
        ),
      ],
    );
  }
}
