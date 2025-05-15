import 'package:flutter/material.dart';

import '../../widgets/error_message.dart';
import 'view_model.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({
    super.key,
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel.init,
        builder: (context, child) {
          if (_viewModel.init.isExecuting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (_viewModel.init.hasError) {
            return const Center(
              child: ErrorMessage(),
            );
          }

          return ListenableBuilder(
            listenable: _viewModel.save,
            builder: (context, child) {
              if (_viewModel.save.hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ユーザー名の保存に失敗しました'),
                    ),
                  );
                  _viewModel.save.resetError();
                });
              }

              return child!;
            },
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (_, __) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _UserNameCard(
                      viewModel: _viewModel,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserNameCard extends StatefulWidget {
  const _UserNameCard({
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  State<_UserNameCard> createState() => _UserNameCardState();
}

class _UserNameCardState extends State<_UserNameCard> {
  @override
  initState() {
    super.initState();
    _controller.text = widget._viewModel.userName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();

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
            if (widget._viewModel.isEditing) ...[
              _UserNameCardTextField(
                controller: _controller,
                hasValidationError: widget._viewModel.hasValidationError,
              ),
              const SizedBox(height: 16),
              _UserNameCardSaveButton(
                enabled: widget._viewModel.canSave,
                onSave: () => widget._viewModel.save(_controller.text),
              ),
            ] else
              _UserNameCardInkWell(
                userName: widget._viewModel.userName,
                onTap: widget._viewModel.startEditing,
              ),
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

class _UserNameCardInkWell extends StatelessWidget {
  const _UserNameCardInkWell({
    required String userName,
    required void Function() onTap,
  })  : _userName = userName,
        _onTap = onTap;

  final String _userName;
  final void Function() _onTap;

  @override
  Widget build(BuildContext context) {
    // InkWellを使用するためにMaterialが必要
    assert(debugCheckHasMaterial(context));

    return InkWell(
      onTap: _onTap,
      child: Text(_userName),
    );
  }
}

class _UserNameCardTextField extends StatelessWidget {
  const _UserNameCardTextField({
    required TextEditingController controller,
    required bool hasValidationError,
  })  : _controller = controller,
        _hasValidationError = hasValidationError;

  final TextEditingController _controller;
  final bool _hasValidationError;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: _controller,
      decoration: InputDecoration(
        errorText: _hasValidationError ? '1文字以上20文字以下にしてください' : null,
      ),
    );
  }
}
