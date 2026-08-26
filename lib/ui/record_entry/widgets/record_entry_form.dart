import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/category_id.dart';
import '../../../domain/models/property_id.dart';
import '../../../domain/models/record_note.dart';
import '../record_entry_view_model.dart';
import 'entry_dropdown.dart';
import 'record_type_selector.dart';

final _dateFormat = DateFormat('yyyy/MM/dd');

/// 記録入力のフォーム本体。
class RecordEntryForm extends StatelessWidget {
  const RecordEntryForm({
    super.key,
    required RecordEntryViewModel viewModel,
    required TextEditingController amountController,
    required TextEditingController noteController,
  }) : _viewModel = viewModel,
       _amountController = amountController,
       _noteController = noteController;

  final RecordEntryViewModel _viewModel;
  final TextEditingController _amountController;
  final TextEditingController _noteController;

  @override
  Widget build(BuildContext context) {
    final isTransfer = _viewModel.type == RecordEntryType.transfer;
    // 保存中の入力変更は、完了時の入力欄クリアと競合するため受け付けない
    final enabled = !_viewModel.submitRecord.running;

    return ListView(
      // キーボードが出ても入力欄が隠れず、スクロールで到達できるようにする
      padding: const EdgeInsets.all(16.0),
      children: [
        if (_hasMissingOptions) ...[
          const _MissingOptionsMessage(),
          const SizedBox(height: 16.0),
        ],
        _DateField(
          date: _viewModel.date,
          firstDate: _viewModel.minSelectableDate,
          lastDate: _viewModel.maxSelectableDate,
          hasError: _viewModel.hasFutureDateError,
          enabled: enabled,
          onChanged: _viewModel.selectDate,
        ),
        const SizedBox(height: 16.0),
        RecordTypeSelector(
          selected: _viewModel.type,
          enabled: enabled,
          onSelected: _viewModel.selectType,
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _amountController,
          enabled: enabled,
          keyboardType: TextInputType.number,
          // 金額は整数のみ。符号や小数点を弾いておくと、検証エラーに至る前に
          // 入力そのものを正しい形へ導ける
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: _viewModel.onAmountChanged,
          // 検証エラーの文言は表示の関心事なのでViewModelではなくここで決める
          decoration: InputDecoration(
            labelText: '金額',
            border: const OutlineInputBorder(),
            errorText: _viewModel.hasAmountError ? '金額は1以上の整数で入力してください' : null,
          ),
        ),
        const SizedBox(height: 16.0),
        if (isTransfer) ...[
          EntryDropdown<PropertyId>(
            // 種別の切替でWidgetの位置が入れ替わるため、キーで役割を固定して
            // 別の選択欄の状態が引き継がれないようにする
            key: const ValueKey('fromProperty'),
            hint: '振替元を選択',
            options: _propertyOptions,
            value: _viewModel.selectedPropertyId,
            enabled: enabled,
            onChanged: _viewModel.selectProperty,
          ),
          const SizedBox(height: 16.0),
          EntryDropdown<PropertyId>(
            key: const ValueKey('toProperty'),
            hint: '振替先を選択',
            options: _propertyOptions,
            value: _viewModel.selectedToPropertyId,
            enabled: enabled,
            onChanged: _viewModel.selectToProperty,
          ),
          if (_viewModel.hasSamePropertyError)
            const _FieldError('振替元と振替先には異なる資産を選択してください'),
        ] else ...[
          EntryDropdown<CategoryId>(
            key: const ValueKey('category'),
            hint: 'カテゴリを選択',
            options: [
              for (final option in _viewModel.categoryOptions)
                (value: option.id, label: option.name),
            ],
            value: _viewModel.selectedCategoryId,
            enabled: enabled,
            onChanged: _viewModel.selectCategory,
          ),
          const SizedBox(height: 16.0),
          EntryDropdown<PropertyId>(
            key: const ValueKey('property'),
            hint: '資産を選択',
            options: _propertyOptions,
            value: _viewModel.selectedPropertyId,
            enabled: enabled,
            onChanged: _viewModel.selectProperty,
          ),
        ],
        const SizedBox(height: 16.0),
        TextField(
          controller: _noteController,
          enabled: enabled,
          keyboardType: TextInputType.text,
          // 上限超過はmaxLengthの入力制限そのもので防ぐ
          maxLength: RecordNote.maxLength,
          onChanged: _viewModel.onNoteChanged,
          decoration: InputDecoration(
            labelText: 'メモ',
            border: const OutlineInputBorder(),
            errorText: _viewModel.hasNoteError
                ? 'メモは${RecordNote.maxLength}文字以内で入力してください'
                : null,
          ),
        ),
        const SizedBox(height: 8.0),
        FilledButton(
          onPressed: _viewModel.canSubmit ? _viewModel.submit : null,
          child: const Text('登録'),
        ),
      ],
    );
  }

  List<({PropertyId value, String label})> get _propertyOptions => [
    for (final property in _viewModel.propertyOptions)
      (value: property.id, label: property.name),
  ];

  /// 保存に必要な選択肢がまだ登録されていないかどうか。
  bool get _hasMissingOptions =>
      _viewModel.propertyOptions.isEmpty ||
      (_viewModel.type != RecordEntryType.transfer &&
          _viewModel.categoryOptions.isEmpty);
}

/// 日付の表示と、日付選択ダイアログの呼び出し。
class _DateField extends StatelessWidget {
  const _DateField({
    required DateTime date,
    required DateTime firstDate,
    required DateTime lastDate,
    required bool hasError,
    required bool enabled,
    required ValueChanged<DateTime> onChanged,
  }) : _date = date,
       _firstDate = firstDate,
       _lastDate = lastDate,
       _hasError = hasError,
       _enabled = enabled,
       _onChanged = onChanged;

  final DateTime _date;
  final DateTime _firstDate;
  final DateTime _lastDate;
  final bool _hasError;
  final bool _enabled;
  final ValueChanged<DateTime> _onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dateFormat.format(_date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              tooltip: '日付を選ぶ',
              // 選べる範囲を当日までに限ることで、未来日付の入力そのものを塞ぐ
              onPressed: _enabled
                  ? () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: _firstDate,
                        lastDate: _lastDate,
                      );
                      if (picked != null) {
                        _onChanged(picked);
                      }
                    }
                  : null,
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
        if (_hasError) const _FieldError('日付は当日までを選択してください'),
      ],
    );
  }
}

/// 選択肢が足りず保存できないことと、次にすべきことを伝える案内。
class _MissingOptionsMessage extends StatelessWidget {
  const _MissingOptionsMessage();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('カテゴリと資産を先に登録してください'),
      ),
    );
  }
}

/// 入力欄に添える検証エラーの文言。
class _FieldError extends StatelessWidget {
  const _FieldError(this._message);

  final String _message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        _message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
