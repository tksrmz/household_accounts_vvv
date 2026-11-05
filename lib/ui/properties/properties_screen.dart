import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/property.dart';
import '../../routing/routes.dart';
import 'properties_view_model.dart';
import 'widgets/delete_property_dialog.dart';
import 'widgets/property_list.dart';

/// 資産一覧画面。
///
/// シェル(タブ)の本体として表示されるため、Scaffoldは持たない。
class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key, required PropertiesViewModel viewModel})
    : _viewModel = viewModel;

  final PropertiesViewModel _viewModel;

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  @override
  void initState() {
    super.initState();
    widget._viewModel.delete.addListener(_onDeleteResult);
  }

  @override
  void dispose() {
    widget._viewModel.delete.removeListener(_onDeleteResult);
    super.dispose();
  }

  /// 削除の失敗をスナックバーで伝える。
  ///
  /// 成功を知らせないのは、削除された行が一覧から消えること自体が結果の表示に
  /// なっているためである。build内ではなくコマンドのリスナーで表示するのは、
  /// スナックバーが「状態」ではなく「一度きりの出来事」だからである(buildは
  /// 再ビルドのたびに走るため、副作用の発火回数を画面の描画回数から切り離す)。
  void _onDeleteResult() {
    if (!widget._viewModel.delete.error) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('資産の削除に失敗しました')));
    // 表示済みのエラーを消し、次の失敗でも再びスナックバーが出るようにする
    widget._viewModel.delete.clearResult();
  }

  /// 削除してよいかを確かめてから削除する。
  ///
  /// 確認をViewModelの状態にしないのは、確認ダイアログが「この操作を本当に
  /// 実行するか」を利用者に問うUIの手続きであり、データの状態ではないため
  /// (ViewModelは確認済みの削除だけを受け取る)。
  Future<void> _confirmAndDelete(Property property) async {
    final confirmed = await showDeletePropertyDialog(
      context,
      propertyName: property.name.value,
    );
    // ダイアログを開いている間にノート切替で画面が作り直されていたら、
    // 古いノートの資産を消さない
    if (!confirmed || !mounted) {
      return;
    }
    await widget._viewModel.delete.execute(property.id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget._viewModel;

    return ListenableBuilder(
      // 削除コマンドの実行状態(実行中の無効化)も描画に反映するため、
      // VMとコマンドの両方を監視する
      listenable: Listenable.merge([viewModel, viewModel.delete]),
      builder: (context, _) {
        // 購読が初回データより先に失敗すると一覧が届かず読み込み中のままに
        // なるため、ローディングよりも先にエラーを確認する
        if (viewModel.loadError != null) {
          return const Center(child: _ErrorMessage());
        }
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return PropertyList(
          properties: viewModel.properties,
          onEditPressed: (property) =>
              context.push(Routes.propertyEdit, extra: property),
          onDeletePressed: _confirmAndDelete,
          deleteEnabled: !viewModel.delete.running,
          onAddPressed: () => context.push(Routes.propertyNew),
        );
      },
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
