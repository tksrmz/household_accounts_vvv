import 'package:flutter/material.dart';

import 'daily_records_view_model.dart';
import 'widgets/daily_record_list.dart';

/// 日次明細画面。
///
/// カレンダーの日セルからボトムナビを覆って開かれるため、自身のScaffoldを持つ。
class DailyRecordsScreen extends StatefulWidget {
  const DailyRecordsScreen({
    super.key,
    required DailyRecordsViewModel viewModel,
  }) : _viewModel = viewModel;

  final DailyRecordsViewModel _viewModel;

  @override
  State<DailyRecordsScreen> createState() => _DailyRecordsScreenState();
}

class _DailyRecordsScreenState extends State<DailyRecordsScreen> {
  @override
  void initState() {
    super.initState();
    widget._viewModel.deleteRecord.addListener(_onDeleteResult);
  }

  @override
  void dispose() {
    widget._viewModel.deleteRecord.removeListener(_onDeleteResult);
    super.dispose();
  }

  /// 削除の失敗をスナックバーで伝える。
  ///
  /// 成功を知らせないのは、削除された行が一覧から消えること自体が結果の表示に
  /// なっているためである。build内ではなくコマンドのリスナーで表示するのは、
  /// スナックバーが「状態」ではなく「一度きりの出来事」だからである(buildは
  /// 再ビルドのたびに走るため、副作用の発火回数を画面の描画回数から切り離す)。
  void _onDeleteResult() {
    if (!widget._viewModel.deleteRecord.error) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('レコードの削除に失敗しました')));
    // 表示済みのエラーを消し、次の失敗でも再びスナックバーが出るようにする
    widget._viewModel.deleteRecord.clearResult();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget._viewModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('${viewModel.year}/${viewModel.month}/${viewModel.day}'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          // 購読が初回データより先に失敗すると一覧が届かず読み込み中のままに
          // なるため、ローディングよりも先にエラーを確認する
          if (viewModel.loadError != null) {
            return const Center(child: _ErrorMessage());
          }
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return DailyRecordList(
            viewModel: viewModel,
            onDeletePressed: viewModel.deleteRecord.execute,
          );
        },
      ),
    );
  }
}

/// 読み込みに失敗したことを伝える表示。
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
