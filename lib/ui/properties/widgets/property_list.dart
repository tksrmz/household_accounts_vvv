import 'package:flutter/material.dart';

import '../../core/formatter.dart';
import '../../../domain/models/property.dart';

/// 資産を1行ずつ並べた一覧と、資産の追加ボタン。
class PropertyList extends StatelessWidget {
  const PropertyList({
    super.key,
    required this.properties,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.deleteEnabled,
    required this.onAddPressed,
  });

  /// 表示する資産。渡された順に並べる。
  final List<Property> properties;

  /// 行の編集アイコンが押されたときに、その行の資産を渡して呼ばれる。
  final void Function(Property property) onEditPressed;

  /// 行の削除アイコンが押されたときに、その行の資産を渡して呼ばれる。
  final void Function(Property property) onDeletePressed;

  /// 削除アイコンを押せるかどうか。
  ///
  /// 削除コマンドは実行中の再実行を黙って捨てるため、実行中は全行の削除アイコンを
  /// 無効化し、押しても何も起きないタップが生まれないようにする。
  final bool deleteEnabled;

  /// 資産の追加ボタンが押されたときに呼ばれる。
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: properties
                .map<Widget>(
                  (property) => _PropertyRow(
                    property: property,
                    onEditPressed: () => onEditPressed(property),
                    onDeletePressed: deleteEnabled
                        ? () => onDeletePressed(property)
                        : null,
                  ),
                )
                .toList(growable: false),
          ),
        ),
        OutlinedButton(
          onPressed: onAddPressed,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.add_circle_outline), Text('資産の追加')],
          ),
        ),
      ],
    );
  }
}

/// 資産1件を表す行。
class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.property,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final Property property;
  final VoidCallback onEditPressed;

  /// `null`のとき削除アイコンは無効表示になる。
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 名前が長くても編集・削除アイコンを画面外へ押し出さないよう、
        // 残りの幅に収めて折り返す
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.name.value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(Formatter.simpleCurrency(property.balance)),
            ],
          ),
        ),
        IconButton(onPressed: onEditPressed, icon: const Icon(Icons.edit)),
        IconButton(onPressed: onDeletePressed, icon: const Icon(Icons.delete)),
      ],
    );
  }
}
