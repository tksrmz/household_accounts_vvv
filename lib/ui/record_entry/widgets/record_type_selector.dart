import 'package:flutter/material.dart';

import '../record_entry_view_model.dart';

/// レコードの種別(収入 / 支出 / 振替)を切り替えるセレクター。
class RecordTypeSelector extends StatelessWidget {
  const RecordTypeSelector({
    super.key,
    required RecordEntryType selected,
    required ValueChanged<RecordEntryType> onSelected,
    bool enabled = true,
  }) : _selected = selected,
       _onSelected = onSelected,
       _enabled = enabled;

  final RecordEntryType _selected;
  final ValueChanged<RecordEntryType> _onSelected;
  final bool _enabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RecordEntryType>(
      segments: const [
        ButtonSegment(value: RecordEntryType.income, label: Text('収入')),
        ButtonSegment(value: RecordEntryType.expense, label: Text('支出')),
        ButtonSegment(value: RecordEntryType.transfer, label: Text('振替')),
      ],
      selected: {_selected},
      // 選択済みのチェックアイコンを出さないのは、狭い画面幅でラベルが
      // 省略されるのを避けるため
      showSelectedIcon: false,
      onSelectionChanged: _enabled
          ? (selection) => _onSelected(selection.first)
          : null,
    );
  }
}
