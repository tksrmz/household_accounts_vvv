import 'package:flutter/material.dart';
import '../../../domain/models/vo/user_id.dart';
import 'view_model.dart';
import 'widgets/error_message.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({
    super.key,
    required UserIdVo userId,
    required this.viewModel,
  }) {
    viewModel.init(userId);
  }

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel,
      builder: (context, state, child) {
        if (state.isUninitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state.isFailed) {
          return const ErrorMessage();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  title: const Text('ユーザー名'),
                  subtitle: Text(state.userName.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
