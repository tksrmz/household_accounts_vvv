import 'package:flutter/material.dart';

import '../../../domain/models/vo/user_name.dart';
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
              listenable: _viewModel.userNameFieldState,
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

  bool _isShowingTextField = false;

  void showTextField() {
    setState(() {
      _isShowingTextField = true;
    });
  }

  void hideTextField() {
    setState(() {
      _isShowingTextField = false;
    });
  }

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
            if (_isShowingTextField) ...[
              _UserNameCardTextField(
                viewModel: widget._viewModel,
                controller: _controller,
              ),
              const SizedBox(height: 16),
              _UserNameCardSaveButton(
                viewModel: widget._viewModel,
                onSave: () {
                  hideTextField();
                  widget._viewModel.save(UserNameVo(_controller.text));
                },
              ),
            ] else
              _UserNameCardInkWell(
                viewModel: widget._viewModel,
                onTap: showTextField,
              ),
          ],
        ),
      ),
    );
  }
}

class _UserNameCardSaveButton extends StatelessWidget {
  const _UserNameCardSaveButton({
    required SettingsViewModel viewModel,
    required void Function() onSave,
  })  : _viewModel = viewModel,
        _onSave = onSave;

  final SettingsViewModel _viewModel;
  final void Function() _onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _viewModel.save.canExecute &&
                  !_viewModel.userNameFieldState.isValidationError
              ? _onSave
              : null,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _UserNameCardInkWell extends StatelessWidget {
  const _UserNameCardInkWell({
    required SettingsViewModel viewModel,
    required void Function() onTap,
  })  : _viewModel = viewModel,
        _onTap = onTap;

  final SettingsViewModel _viewModel;
  final void Function() _onTap;

  @override
  Widget build(BuildContext context) {
    // InkWellを使用するためにMaterialが必要
    assert(debugCheckHasMaterial(context));

    // FIXME 後で消す
    final tmpOnTap = () {
      _onTap();
      _viewModel.userNameFieldState.startEditing();
    };

    return InkWell(
      onTap: tmpOnTap,
      child: Text(_viewModel.userName),
    );
  }
}

class _UserNameCardTextField extends StatelessWidget {
  const _UserNameCardTextField({
    required SettingsViewModel viewModel,
    required TextEditingController controller,
  })  : _viewModel = viewModel,
        _controller = controller;

  final SettingsViewModel _viewModel;
  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: _controller,
      onChanged: _viewModel.userNameFieldState.updateUserName,
      decoration: InputDecoration(
        errorText: _viewModel.userNameFieldState.isValidationError
            ? '1文字以上20文字以下にしてください'
            : null,
      ),
    );
  }
}
