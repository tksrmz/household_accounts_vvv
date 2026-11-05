import 'package:flutter/material.dart';

/// 資産[propertyName]を削除してよいかを確かめるダイアログを開く。
///
/// 「削除する」を選んだときだけtrueを返す。ダイアログの外をタップして閉じた
/// 場合も、削除しない選択として扱う(誤操作で資産を消さないため)。
///
/// 削除した資産は元に戻せず、その資産を参照していた記録は「削除済み」と
/// 表示されるようになる。タップ1回で取り返しのつかない結果にしないよう、
/// 削除の前に確認を挟む。
Future<bool> showDeletePropertyDialog(
  BuildContext context, {
  required String propertyName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => DeletePropertyDialog(propertyName: propertyName),
  );
  return confirmed ?? false;
}

/// 資産の削除を確かめるダイアログの中身。
///
/// 「削除する」でtrue、「削除しない」でfalseを返して閉じる。開くときは
/// [showDeletePropertyDialog]を使う(Widgetとして公開しているのは、表示を
/// goldenテストで固定するため)。
class DeletePropertyDialog extends StatelessWidget {
  const DeletePropertyDialog({super.key, required String propertyName})
    : _propertyName = propertyName;

  final String _propertyName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('本当に『$_propertyName』を削除しますか？'),
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
