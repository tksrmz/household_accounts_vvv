import 'package:flutter/material.dart';

import 'record_entry_view_model.dart';
import 'widgets/record_entry_form.dart';

/// 記録入力画面。
///
/// シェル(タブ)の本体として表示されるため、Scaffoldは持たない。
class RecordEntryScreen extends StatefulWidget {
  const RecordEntryScreen({super.key, required RecordEntryViewModel viewModel})
    : _viewModel = viewModel;

  final RecordEntryViewModel _viewModel;

  @override
  State<RecordEntryScreen> createState() => _RecordEntryScreenState();
}

class _RecordEntryScreenState extends State<RecordEntryScreen> {
  // 入力欄の文字列はWidget側の関心事(カーソル位置や日本語入力の変換途中を含む)
  // なのでViewModelではなくこのStateが所有する
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget._viewModel.submitRecord.addListener(_onSubmitResult);
  }

  @override
  void dispose() {
    widget._viewModel.submitRecord.removeListener(_onSubmitResult);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 保存の成否をスナックバーで伝え、成功時は入力欄を次の入力に備えて空にする。
  ///
  /// build内ではなくコマンドのリスナーで表示するのは、スナックバーが
  /// 「状態」ではなく「一度きりの出来事」だからである(buildは再ビルドのたびに
  /// 走るため、副作用の発火回数を画面の描画回数から切り離す)。
  void _onSubmitResult() {
    final submitRecord = widget._viewModel.submitRecord;

    if (submitRecord.completed) {
      // 金額とメモを空にするViewModel側の後始末と対にする(日付・種別・選択は
      // 次の記録でも同じことが多いため残す)
      _amountController.clear();
      _noteController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('レコードを登録しました')));
      // 表示済みの結果を消し、次の保存でも再びスナックバーが出るようにする
      submitRecord.clearResult();
      return;
    }

    if (submitRecord.error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('レコードの登録に失敗しました')));
      submitRecord.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget._viewModel,
      builder: (context, _) {
        // 購読が初回データより先に失敗すると選択肢が届かず読み込み中のままに
        // なるため、ローディングよりも先にエラーを確認する
        if (widget._viewModel.optionsError != null) {
          return const Center(child: _ErrorMessage());
        }
        if (widget._viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return _RecordEntryContent(
          viewModel: widget._viewModel,
          amountController: _amountController,
          noteController: _noteController,
        );
      },
    );
  }
}

class _RecordEntryContent extends StatelessWidget {
  const _RecordEntryContent({
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
    return ListenableBuilder(
      // 保存コマンドの実行状態にも追従させる。ViewModel自体は保存の開始時に
      // 通知しないため、実行開始の時点で入力欄と登録ボタンを無効化するには
      // コマンドの通知も購読する必要がある
      listenable: Listenable.merge([_viewModel, _viewModel.submitRecord]),
      builder: (_, _) => RecordEntryForm(
        viewModel: _viewModel,
        amountController: _amountController,
        noteController: _noteController,
      ),
    );
  }
}

/// 選択肢の読み込みに失敗したことを伝える表示。
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16.0),
          const Text('エラーが発生しました。'),
          const SizedBox(height: 8.0),
          const Text('アプリを再起動してください。'),
        ],
      ),
    );
  }
}
