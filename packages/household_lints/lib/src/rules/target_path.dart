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
