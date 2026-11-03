import 'package:flutter/material.dart';

import '../../../common/logic/formatter.dart';
import '../../../domain/models/record.dart';
import '../daily_records_view_model.dart';

/// 1日分のレコードを1行ずつ並べる明細の一覧。
class DailyRecordList extends StatelessWidget {
  const DailyRecordList({
    super.key,
    required this.viewModel,
    required this.onDeletePressed,
    required this.deleteEnabled,
  });

  /// 表示するレコードと、ID→名前の逆引きを提供するViewModel。
  final DailyRecordsViewModel viewModel;

  /// 行の削除アイコンが押されたときに、その行のレコードを渡して呼ばれる。
  final void Function(Record record) onDeletePressed;

  /// 削除アイコンを押せるかどうか。
  ///
  /// 削除コマンドは実行中の再実行を黙って捨てるため、実行中は全行の削除アイコンを
  /// 無効化し、押しても何も起きないタップが生まれないようにする。
  final bool deleteEnabled;

  // 参照先のカテゴリ・資産が既に削除されている場合の表示。名前を空欄にすると
  // その行が何の記録なのか読み取れなくなるため、削除済みであることを明示する。
  static const _deletedReferenceName = '削除済み';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: viewModel.records
          .map<Widget>(
            (record) => _DailyRecordRow(
              leadingText: _leadingTextOf(record),
              amountText: _amountTextOf(record),
              onDeletePressed: deleteEnabled
                  ? () => onDeletePressed(record)
                  : null,
            ),
          )
          .toList(growable: false),
    );
  }

  /// 行の先頭に表示する、レコードの内容を表す文字列。
  String _leadingTextOf(Record record) => switch (record) {
    IncomeRecord(:final categoryId, :final note) =>
      '${viewModel.incomeCategoryNameOf(categoryId) ?? _deletedReferenceName}'
          '@${note.value}',
    ExpenseRecord(:final categoryId, :final note) =>
      '${viewModel.expenseCategoryNameOf(categoryId) ?? _deletedReferenceName}'
          '@${note.value}',
    TransferRecord(:final fromPropertyId, :final toPropertyId) =>
      '${viewModel.propertyNameOf(fromPropertyId) ?? _deletedReferenceName}'
          '→${viewModel.propertyNameOf(toPropertyId) ?? _deletedReferenceName}',
  };

  /// 行の末尾に表示する金額。収入だけが残高を増やすため符号を添える。
  String _amountTextOf(Record record) {
    final amount = Formatter.simpleCurrency(record.amount.value);
    return record is IncomeRecord ? '+$amount' : amount;
  }
}

/// レコード1件を表す行。
class _DailyRecordRow extends StatelessWidget {
  const _DailyRecordRow({
    required this.leadingText,
    required this.amountText,
    required this.onDeletePressed,
  });

  final String leadingText;
  final String amountText;

  /// `null`のとき削除アイコンは無効表示になる。
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(leadingText)),
        Text(amountText),
        IconButton(onPressed: onDeletePressed, icon: const Icon(Icons.delete)),
      ],
    );
  }
}
