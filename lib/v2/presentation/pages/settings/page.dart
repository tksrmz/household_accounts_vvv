import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/user_auth.dart';
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
            listenable: _viewModel.userNameFieldState,
            builder: (context, _) {
              if (_viewModel.userNameFieldState.isSavingError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ユーザー名の保存に失敗しました'),
                    ),
                  );
                  _viewModel.userNameFieldState.clearSaveError();
                });
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _UserNameCard(
                      viewModel: _viewModel,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserNameCard extends StatelessWidget {
  const _UserNameCard({
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  bool get _displaysUserNameTextField =>
      _viewModel.userNameFieldState.isEditing ||
      _viewModel.userNameFieldState.isValidationError;

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
            if (_displaysUserNameTextField) ...[
              _UserNameCardTextField(state: _viewModel.userNameFieldState),
              const SizedBox(height: 16),
              _UserNameCardSaveButton(viewModel: _viewModel),
            ] else
              _UserNameCardInkWell(state: _viewModel.userNameFieldState),
          ],
        ),
      ),
    );
  }
}

class _UserNameCardSaveButton extends StatelessWidget {
  const _UserNameCardSaveButton({
    required SettingsViewModel viewModel,
  }) : _viewModel = viewModel;

  final SettingsViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _viewModel.userNameFieldState.isEditing
              ? () async {
                  await _viewModel.save();
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
  }) : _state = state;

  final UserNameFieldState _state;

  @override
  Widget build(BuildContext context) {
    // InkWellを使用するためにMaterialが必要
    assert(debugCheckHasMaterial(context));

    return InkWell(
      onTap: _state.startEditing,
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
