import 'package:analyzer/dart/ast/ast.dart';

/// [path] が `lib/data/repositories/` 配下のファイルを指しているかどうかを判定する。
///
/// 解析対象のファイルパスは実行環境によって区切り文字が異なる
/// (Windowsは`\`、CI(ubuntu)や多くのツール内部表現は`/`)。
/// パス文字列の部分一致ではなく区切り文字でセグメント分割してから判定することで、
/// 区切り文字の混在や偶然の部分一致(`xlib/data/repositories.dart`等)に
/// 影響されない一致判定にしている。
bool isRepositoryImplementationPath(String path) {
  final segments = path
      .split(RegExp(r'[\\/]'))
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);

  for (var i = 0; i + 2 < segments.length; i++) {
    final isLibDataRepositories =
        segments[i] == 'lib' &&
        segments[i + 1] == 'data' &&
        segments[i + 2] == 'repositories';
    if (isLibDataRepositories) {
      return true;
    }
  }
  return false;
}

/// [name] がRepositoryの公開API規約群の対象となるクラス名/mixin名かどうかを判定する。
///
/// 判定基準は「`Repository`で終わるかどうか」のみとする。パス判定
/// ([isRepositoryImplementationPath])だけで対象を絞ると、将来
/// `lib/data/repositories/`配下にDTOやヘルパー(freezedの生成getterを持つ
/// クラス等)が置かれた場合に誤検知するため、クラス名判定を組み合わせて絞り込む。
bool isRepositoryClassName(String name) => name.endsWith('Repository');

/// [node] を直接囲むクラスまたはmixin宣言の名前を返す。
///
/// クラス・mixin宣言に属さない宣言(トップレベル関数、extension等)の場合は
/// `null`を返す。Dartにクラスのネスト宣言は存在しないため、祖先を辿って
/// 最初に見つかったクラス/mixin宣言がそのまま「直接囲む」ものになる。
String? enclosingClassOrMixinName(AstNode node) {
  for (var current = node.parent; current != null; current = current.parent) {
    if (current is ClassDeclaration) {
      return current.namePart.typeName.lexeme;
    }
    if (current is MixinDeclaration) {
      return current.name.lexeme;
    }
  }
  return null;
}

/// [node] がRepositoryの公開API規約群(`repository_must_use_result_guard`、
/// `repository_no_bare_future`、`repository_no_public_properties`)の対象かどうかを判定する。
///
/// 「[filePath]が`lib/data/repositories/`配下であること」と「[node]を直接囲む
/// クラス/mixin名が`Repository`で終わること」の両方を満たす場合のみ対象とする。
bool isRepositoryApiDeclaration(AstNode node, String? filePath) {
  if (filePath == null || !isRepositoryImplementationPath(filePath)) {
    return false;
  }
  final enclosingName = enclosingClassOrMixinName(node);
  return enclosingName != null && isRepositoryClassName(enclosingName);
}
