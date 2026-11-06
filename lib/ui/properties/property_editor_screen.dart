import 'package:flutter/material.dart';

import '../../domain/models/property_name.dart';
import 'property_editor_view_model.dart';

/// 資産エディタ画面(追加・編集)。
///
/// 資産一覧からボトムナビを覆って開かれるため、自身のScaffoldを持つ。
class PropertyEditorScreen extends StatefulWidget {
  const PropertyEditorScreen({
    super.key,
    required PropertyEditorViewModel viewModel,
  }) : _viewModel = viewModel;

  final PropertyEditorViewModel _viewModel;

  @override
  State<PropertyEditorScreen> createState() => _PropertyEditorScreenState();
}

class _PropertyEditorScreenState extends State<PropertyEditorScreen> {
  // 入力欄の文字列はWidget側の関心事(カーソル位置や日本語入力の変換途中を含む)
  // なのでViewModelではなくこのStateが所有する。初期値だけはViewModelから受け取る
  // (編集では編集対象の資産の内容から始めるため)
  late final TextEditingController _nameController = TextEditingController(
    text: widget._viewModel.nameInput,
  );
  late final TextEditingController _balanceController = TextEditingController(
    text: widget._viewModel.balanceInput,
  );

  @override
  void initState() {
    super.initState();
    widget._viewModel.save.addListener(_onSaveResult);
  }

  @override
  void dispose() {
    widget._viewModel.save.removeListener(_onSaveResult);
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// 保存に成功したら画面を閉じ、失敗したらスナックバーで伝えて画面に留まる。
  ///
  /// 失敗しても閉じないのは、閉じると入力内容が失われ、保存できていないことにも
  /// 気づけないためである。build内ではなくコマンドのリスナーで扱うのは、画面遷移や
  /// スナックバーが「状態」ではなく「一度きりの出来事」だからである(buildは
  /// 再ビルドのたびに走るため、副作用の発火回数を画面の描画回数から切り離す)。
  void _onSaveResult() {
    final save = widget._viewModel.save;

    if (save.completed) {
      Navigator.of(context).pop();
      return;
    }

    if (save.error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('資産の保存に失敗しました')));
      // 表示済みのエラーを消し、次の失敗でも再びスナックバーが出るようにする
      save.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget._viewModel;

    return Scaffold(
      appBar: AppBar(title: Text(viewModel.isEditing ? '編集' : '資産の追加')),
      body: ListenableBuilder(
        // 保存コマンドの実行状態にも追従させる。ViewModel自体は保存の開始時に
        // 通知しないため、実行開始の時点で入力欄と保存ボタンを無効化するには
        // コマンドの通知も購読する必要がある
        listenable: Listenable.merge([viewModel, viewModel.save]),
        builder: (context, _) {
          // 保存中の入力変更は、保存した内容と画面の表示を食い違わせるため受け付けない
          final enabled = !viewModel.save.running;

          return ListView(
            // キーボードが出ても入力欄が隠れず、スクロールで到達できるようにする
            padding: const EdgeInsets.all(16.0),
            children: [
              TextField(
                controller: _nameController,
                enabled: enabled,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                // maxLengthは見た目の文字数(書記素)で数えるため、ドメインの上限
                // (UTF-16コード単位)との差はViewModelのライブ検証が補う
                maxLength: PropertyName.maxLength,
                onChanged: viewModel.onNameChanged,
                // 検証エラーの文言は表示の関心事なのでViewModelではなくここで決める
                decoration: InputDecoration(
                  labelText: '資産名',
                  helperText: '1文字以上${PropertyName.maxLength}文字以内',
                  border: const OutlineInputBorder(),
                  errorText: viewModel.hasNameError
                      ? '資産名は1文字以上${PropertyName.maxLength}文字以内で入力してください'
                      : null,
                  // 文字数カウンタと横並びになるため、狭い画面では1行に収まらない
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _balanceController,
                enabled: enabled,
                // 残高は支出で負になりうるため、マイナス記号を打てるキーボードにする
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                // 入力フォーマッタで文字を取り除かない。取り除くと不正な入力が有効な
                // 別の値に化けて保存できてしまう(「1234.50」→「123450」、「1e3」→「13」、
                // 先頭固定のパターンなら「100,000」→「100」)。入力はそのままViewModelの
                // ライブ検証に渡し、整数でなければエラー表示で保存できなくする
                onChanged: viewModel.onBalanceChanged,
                decoration: InputDecoration(
                  labelText: '資産額',
                  border: const OutlineInputBorder(),
                  errorText: viewModel.hasBalanceError
                      ? '資産額は整数で入力してください'
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: viewModel.canSave ? viewModel.submit : null,
                  child: const Text('保存'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
