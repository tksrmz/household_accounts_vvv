import 'package:flutter/material.dart';

import '../../../domain/models/user_name.dart';
import '../settings_view_model.dart';

/// ユーザー名を表示・編集するカード。
class UserNameCard extends StatefulWidget {
  const UserNameCard({super.key, required SettingsViewModel viewModel})
    : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  State<UserNameCard> createState() => _UserNameCardState();
}

class _UserNameCardState extends State<UserNameCard> {
  @override
  void initState() {
    super.initState();
    _controller.text = widget._viewModel.userName;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget._viewModel.startEditing();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ユーザー名', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            _UserNameCardTextField(
              controller: _controller,
              focusNode: _focusNode,
              // 保存中は編集不可にする。保存中の入力変更を許すと、完了後の
              // 表示名との同期(巻き戻し)と競合するため
              enabled: !widget._viewModel.isSaving,
              hasValidationError: widget._viewModel.hasValidationError,
              onChanged: widget._viewModel.onUserNameChanged,
            ),
            if (widget._viewModel.isEditing) ...[
              const SizedBox(height: 16),
              _UserNameCardSaveButton(
                enabled: widget._viewModel.canSave,
                onSave: () async {
                  _focusNode.unfocus(); // フォーカスを外す
                  await widget._viewModel.save(_controller.text);
                  // 検証エラーのときは入力し直せるよう入力値をそのまま残す。
                  // それ以外は表示名の唯一の源泉であるViewModelへ入力を合わせる
                  // (保存に失敗したときは編集前の値へ巻き戻り、成功したときは
                  // 保存した値のままで変化しない)。保存コマンドのエラー状態を
                  // 見ないのは、失敗を伝えるスナックバーがそれを消費済みのため。
                  if (!widget._viewModel.hasValidationError) {
                    _controller.text = widget._viewModel.userName;
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UserNameCardSaveButton extends StatelessWidget {
  const _UserNameCardSaveButton({
    required bool enabled,
    required void Function() onSave,
  }) : _enabled = enabled,
       _onSave = onSave;

  final bool _enabled;
  final void Function() _onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _enabled ? _onSave : null,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _UserNameCardTextField extends StatelessWidget {
  const _UserNameCardTextField({
    required TextEditingController controller,
    required bool enabled,
    required bool hasValidationError,
    required FocusNode focusNode,
    required void Function(String) onChanged,
  }) : _controller = controller,
       _enabled = enabled,
       _hasValidationError = hasValidationError,
       _focusNode = focusNode,
       _onChanged = onChanged;

  final TextEditingController _controller;
  final bool _enabled;
  final bool _hasValidationError;
  final FocusNode _focusNode;
  final void Function(String) _onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      autofocus: false,
      autocorrect: false,
      enabled: _enabled,
      // 20文字超はmaxLengthの入力制限そのもので防ぐ(この画面のライブ検証に
      // 到達しうる不正は0文字のみ)
      maxLength: UserName.maxLength,
      controller: _controller,
      focusNode: _focusNode,
      onChanged: _onChanged,
      // 検証エラーの文言は表示の関心事なのでViewModelではなくここで決める
      decoration: InputDecoration(
        errorText: _hasValidationError ? '1文字以上20文字以下にしてください' : null,
      ),
    );
  }
}
