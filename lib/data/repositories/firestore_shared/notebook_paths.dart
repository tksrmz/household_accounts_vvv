import '../../../domain/models/notebook.dart';

/// 個人ノート/共有ノートのFirestore上のルートパス解決をここに集約する。
///
/// 収入・支出・資産・カテゴリなど、ノートの中身を扱う各Repositoryは
/// このパスの下にコレクションをぶら下げるだけでよく、
/// パスの組み立てをRepositoryごとに重複させない。
String notebookPath(Notebook notebook) => switch (notebook) {
  PersonalNotebook(:final uid) => 'personalNotes/${uid.value}',
  SharedNotebook(:final pairId) => 'sharedNotes/${pairId.value}',
};
