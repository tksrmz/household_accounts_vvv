import 'package:flutter/material.dart';

/// 記録入力のフォームで使う選択欄。
///
/// カテゴリ・資産(振替元)・振替先で見た目と振る舞いを揃えるため、選択肢の型を
/// 問わない汎用のWidgetとして持つ。
class EntryDropdown<T> extends StatelessWidget {
  const EntryDropdown({
    super.key,
    required String hint,
    required List<({T value, String label})> options,
    required T? value,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
  }) : _hint = hint,
       _options = options,
       _value = value,
       _onChanged = onChanged,
       _enabled = enabled;

  final String _hint;
  final List<({T value, String label})> _options;
  final T? _value;
  final ValueChanged<T?> _onChanged;
  final bool _enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: _value,
      hint: Text(_hint),
      // 長い名前でも枠からはみ出さないよう、幅いっぱいに広げて省略表示させる
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: [
        for (final option in _options)
          DropdownMenuItem<T>(value: option.value, child: Text(option.label)),
      ],
      onChanged: _enabled ? _onChanged : null,
    );
  }
}
