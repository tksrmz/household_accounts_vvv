import 'package:flutter/material.dart';

/// カテゴリ1件を表す行。表示する文言、編集アイコン、削除アイコンを並べる。
class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.label,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  /// 行に表示する文言(収入カテゴリは名前、支出カテゴリは名前と予算)。
  final String label;

  final VoidCallback onEditPressed;

  /// `null`のとき削除アイコンは無効表示になる。
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 名前が長くても編集・削除アイコンを画面外へ押し出さないよう、
        // 残りの幅に収めて折り返す
        Expanded(child: Text(label)),
        IconButton(onPressed: onEditPressed, icon: const Icon(Icons.edit)),
        IconButton(onPressed: onDeletePressed, icon: const Icon(Icons.delete)),
      ],
    );
  }
}
