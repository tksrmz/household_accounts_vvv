import 'package:flutter/material.dart';

import '../../domain/models/category_name.dart';
import 'category_editor_view_model.dart';

/// カテゴリエディタ画面(追加・編集)。
///
/// カテゴリ一覧からボトムナビを覆って開かれるため、自身のScaffoldを持つ。
class CategoryEditorScreen extends StatefulWidget {
  const CategoryEditorScreen({
    super.key,
    required CategoryEditorViewModel viewModel,
  }) : _viewModel = viewModel;

  final CategoryEditorViewModel _viewModel;

  @override
  State<CategoryEditorScreen> createState() => _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends State<CategoryEditorScreen> {
  // 入力欄の文字列はWidget側の関心事(カーソル位置や日本語入力の変換途中を含む)
  // なのでViewModelではなくこのStateが所有する。初期値だけはViewModelから受け取る
  // (編集では編集対象のカテゴリの内容から始めるため)。予算の入力欄は収入を
  // 選んでいる間は表示されないが、コントローラはこのStateが持ち続けるので、
  // 種別を切り替えても入力は残る
  late final TextEditingController _nameController = TextEditingController(
    text: widget._viewModel.nameInput,
  );
  late final TextEditingController _budgetController = TextEditingController(
    text: widget._viewModel.budgetInput,
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
    _budgetController.dispose();
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
      ).showSnackBar(const SnackBar(content: Text('カテゴリの保存に失敗しました')));
      // 表示済みのエラーを消し、次の失敗でも再びスナックバーが出るようにする
      save.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget._viewModel;

    return Scaffold(
      appBar: AppBar(title: Text(viewModel.isEditing ? '編集' : 'カテゴリの追加')),
      body: ListenableBuilder(
        // 保存コマンドの実行状態にも追従させる。ViewModel自体は保存の開始時に
        // 通知しないため、実行開始の時点で入力欄と保存ボタンを無効化するには
        // コマンドの通知も購読する必要がある
        listenable: Listenable.merge([viewModel, viewModel.save]),
        builder: (context, _) {
          // 保存中の入力変更は、保存した内容と画面の表示を食い違わせるため受け付けない
          final enabled = !viewModel.save.running;
          final isExpense = viewModel.kind == CategoryKind.expense;

          return ListView(
            // キーボードが出ても入力欄が隠れず、スクロールで到達できるようにする
            padding: const EdgeInsets.all(16.0),
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: ToggleButtons(
                    isSelected: [
                      for (final kind in CategoryKind.values)
                        kind == viewModel.kind,
                    ],
                    constraints: BoxConstraints(
                      minWidth:
                          constraints.maxWidth / CategoryKind.values.length -
                          10,
                      minHeight: 48.0,
                    ),
                    // 編集では切り替えられないが、nullを渡して無効表示にはしない
                    // (グレーアウトすると、どちらの種別を編集しているのか読み取り
                    // にくくなるため)。押しても変わらないことはViewModelが保証する。
                    // 保存中だけは他の入力欄と同じく無効にする
                    onPressed: enabled
                        ? (index) => viewModel.onKindSelected(
                            CategoryKind.values[index],
                          )
                        : null,
                    children: const [Text('収入'), Text('支出')],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _nameController,
                enabled: enabled,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                // maxLengthは見た目の文字数(書記素)で数えるため、ドメインの上限
                // (UTF-16コード単位)との差はViewModelのライブ検証が補う
                maxLength: CategoryName.maxLength,
                onChanged: viewModel.onNameChanged,
                // 検証エラーの文言は表示の関心事なのでViewModelではなくここで決める
                decoration: InputDecoration(
                  labelText: 'カテゴリ名',
                  helperText: '1文字以上${CategoryName.maxLength}文字以下',
                  border: const OutlineInputBorder(),
                  errorText: viewModel.hasNameError
                      ? 'カテゴリ名は1文字以上${CategoryName.maxLength}文字以下で入力してください'
                      : null,
                  // 文字数カウンタと横並びになるため、狭い画面では1行に収まらない
                  errorMaxLines: 2,
                ),
              ),
              if (isExpense) ...[
                const SizedBox(height: 16.0),
                TextField(
                  controller: _budgetController,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  // 入力フォーマッタで文字を取り除かない。取り除くと不正な入力が有効な
                  // 別の値に化けて保存できてしまう(「1234.50」→「123450」、
                  // 「1e3」→「13」など)。入力はそのままViewModelのライブ検証に渡し、
                  // 0以上の整数でなければエラー表示で保存できなくする
                  onChanged: viewModel.onBudgetChanged,
                  decoration: InputDecoration(
                    labelText: '予算',
                    border: const OutlineInputBorder(),
                    errorText: viewModel.hasBudgetError
                        ? '予算は0以上の整数で入力してください'
                        : null,
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: viewModel.canSave ? viewModel.submit : null,
                  child: const Text('登録'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
