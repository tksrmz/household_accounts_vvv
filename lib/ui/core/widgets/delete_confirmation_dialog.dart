import 'package:flutter/material.dart';

/// [targetName](資産名・カテゴリ名など)を削除してよいかを確かめるダイアログを開く。
///
/// 「削除する」を選んだときだけtrueを返す。ダイアログの外をタップして閉じた
/// 場合も、削除しない選択として扱う(誤操作で消さないため)。
///
/// 資産やカテゴリは、参照する記録の有無を確かめずに削除する。削除したものは
/// 元に戻せず、参照していた記録は「削除済み」と表示されるようになる。
/// タップ1回で取り返しのつかない結果にしないよう、削除の前に確認を挟む。
Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  required String targetName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => DeleteConfirmationDialog(targetName: targetName),
  );
  return confirmed ?? false;
}

/// 削除を確かめるダイアログの中身。
///
/// 「削除する」でtrue、「削除しない」でfalseを返して閉じる。開くときは
/// [showDeleteConfirmationDialog]を使う(Widgetとして公開しているのは、表示を
/// goldenテストで固定するため)。
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key, required String targetName})
    : _targetName = targetName;

  final String _targetName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('本当に「$_targetName」を削除しますか？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('削除しない'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('削除する'),
        ),
      ],
    );
  }
}
