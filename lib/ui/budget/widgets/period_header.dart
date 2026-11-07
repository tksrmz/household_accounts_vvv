import 'package:flutter/material.dart';

/// 表示中の期間のラベルと、前後の期間へ移動する矢印を並べたヘッダ。
class PeriodHeader extends StatelessWidget {
  const PeriodHeader({
    super.key,
    required this.label,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  /// 表示中の期間を表す文言(「2026年7月度（6/16〜7/15）」など)。
  final String label;

  /// 前の期間へ移動する操作。`null`のとき矢印は押下不可になる。
  final VoidCallback? onPreviousPressed;

  /// 次の期間へ移動する操作。`null`のとき矢印は押下不可になる。
  final VoidCallback? onNextPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: onPreviousPressed,
        ),
        // 狭い画面でもラベルが矢印を画面外へ押し出さないよう、残りの幅に収める
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: onNextPressed,
        ),
      ],
    );
  }
}
