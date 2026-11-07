import 'package:flutter/material.dart';

/// 見出しと、1種別ぶんのカテゴリの一覧(または読み込み中・エラー・0件の表示)。
///
/// 収入カテゴリと支出カテゴリは別々に購読するため、読み込み中やエラーの表示も
/// 種別ごとにこのセクションの中で出す(片方のエラーでもう片方を隠さない)。
class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.title,
    required this.isLoading,
    required this.hasError,
    required this.emptyMessage,
    required this.rows,
  });

  /// セクションの見出し(「収入カテゴリ」など)。
  final String title;

  /// 初回の読み込みが完了していないかどうか。
  final bool isLoading;

  /// 購読が失敗しているかどうか。[isLoading]より優先して表示する(初回データより
  /// 先に失敗すると一覧が届かず読み込み中のままになるため)。
  final bool hasError;

  /// カテゴリが1件も無いときに出す文言。
  final String emptyMessage;

  /// カテゴリ1件ずつの行。渡された順に並べる。
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            title,
            style: DefaultTextStyle.of(
              context,
            ).style.apply(fontSizeFactor: 1.25),
          ),
        ),
        _body(),
      ],
    );
  }

  Widget _body() {
    if (hasError) {
      return const _ErrorMessage();
    }
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (rows.isEmpty) {
      return Text(emptyMessage);
    }
    return Column(children: rows);
  }
}

/// 読み込みに失敗したことを伝える表示。
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
        child: Column(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16.0),
            const Text('エラーが発生しました。'),
            const SizedBox(height: 8.0),
            const Text('アプリを再起動してください。'),
          ],
        ),
      ),
    );
  }
}
