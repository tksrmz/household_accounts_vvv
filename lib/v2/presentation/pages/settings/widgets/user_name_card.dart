import 'package:flutter/material.dart';

import '../../../../domain/models/vo/user_name.dart';
import '../view_model.dart';

class UserNameCard extends StatefulWidget {
  const UserNameCard({
    super.key,
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  State<UserNameCard> createState() => _UserNameCardState();
}

class _UserNameCardState extends State<UserNameCard> {
  @override
  initState() {
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
            Text(
              'ユーザー名',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            _UserNameCardTextField(
              controller: _controller,
              focusNode: _focusNode,
              hasValidationError: widget._viewModel.hasValidationError,
            ),
            if (widget._viewModel.isEditing) ...[
              const SizedBox(height: 16),
              _UserNameCardSaveButton(
                enabled: widget._viewModel.canSave,
                onSave: () async {
                  _focusNode.unfocus(); // フォーカスを外す
                  await widget._viewModel.save(_controller.text);
                  if (widget._viewModel.save.hasError) {
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
  })  : _enabled = enabled,
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
    required bool hasValidationError,
    required FocusNode focusNode,
  })  : _controller = controller,
        _hasValidationError = hasValidationError,
        _focusNode = focusNode;

  final TextEditingController _controller;
  final bool _hasValidationError;
  final FocusNode _focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.text,
      autofocus: false,
      autocorrect: false,
      maxLength: UserNameVo.maxLength,
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        errorText: _hasValidationError ? '1文字以上20文字以下にしてください' : null,
      ),
    );
  }
}
