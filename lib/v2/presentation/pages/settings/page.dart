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
                  // TODO ここを save.resetError()に変える
                  _viewModel.userNameFieldState.clearSaveError();
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
  bool isShowingTextField = false;

  void showTextField() {
    setState(() {
      isShowingTextField = true;
    });
  }

  void hideTextField() {
    setState(() {
      isShowingTextField = false;
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
            if (isShowingTextField) ...[
              _UserNameCardTextField(
                  state: widget._viewModel.userNameFieldState),
              const SizedBox(height: 16),
              _UserNameCardSaveButton(
                viewModel: widget._viewModel,
                onSave: hideTextField,
              ),
            ] else
              _UserNameCardInkWell(
                state: widget._viewModel.userNameFieldState,
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
    // FIXME 後で消す
    final tmp = () async {
      _onSave();
      await _viewModel.save();
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _viewModel.userNameFieldState.isEditing
              ? () async {
                  await tmp();
                }
              : null,
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _UserNameCardInkWell extends StatelessWidget {
  const _UserNameCardInkWell({
    required UserNameFieldState state,
    required void Function() onTap,
  })  : _state = state,
        _onTap = onTap;

  final UserNameFieldState _state;
  final void Function() _onTap;

  @override
  Widget build(BuildContext context) {
    // InkWellを使用するためにMaterialが必要
    assert(debugCheckHasMaterial(context));

    // FIXME 後で消す
    final tmpOnTap = () {
      _onTap();
      _state.startEditing();
    };

    return InkWell(
      onTap: tmpOnTap,
      child: Text(_state.userName),
    );
  }
}

class _UserNameCardTextField extends StatefulWidget {
  const _UserNameCardTextField({
    required UserNameFieldState state,
  }) : _state = state;

  final UserNameFieldState _state;

  @override
  State<_UserNameCardTextField> createState() => _UserNameCardTextFieldState();
}

class _UserNameCardTextFieldState extends State<_UserNameCardTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget._state.userName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: _controller,
      onChanged: widget._state.updateUserName,
      decoration: InputDecoration(
        errorText:
            widget._state.isValidationError ? '1文字以上20文字以下にしてください' : null,
      ),
    );
  }
}
