import 'package:analyzer/dart/element/element.dart';

/// [element] がアプリの`Result`型(`lib/utils/result.dart`で定義されたもの)を
/// 指しているかどうかを判定する。
///
/// 「要素名が`Result`であること」に加え、「要素の宣言元ライブラリのURIパスが
/// `utils/result.dart`で終わること」を要求する。名前だけの判定では、検証対象
/// ファイル内でローカルに`class Result`を定義したり、無関係な他パッケージ
/// (例: result_dartパッケージの`Result`)を使っていても素通りしてしまうため、
/// ライブラリの位置も合わせて確認する。
///
/// 一方で「`package:household_accounts/utils/result.dart`への完全一致」という
/// 厳密な同一性判定は採らない。household_lintsパッケージをアプリ本体
/// (package:household_accounts)へ依存させることになり、テストフィクスチャ
/// (`package:test/utils/result.dart`相当のスタブ)まで実物のResult型に
/// 差し替える必要が生じ、プラグインパッケージがアプリから独立している
/// という既存の構成を壊すため。ライブラリURIの「パスの末尾」だけを見ることで、
/// 実アプリ(`package:household_accounts/utils/result.dart`)とテスト
/// フィクスチャ(`package:test/utils/result.dart`)の双方を「utils/result.dart」
/// という共通の配置規約で捕捉しつつ、他パッケージの同名クラスやローカル定義は
/// 除外する。
bool isResultElement(InterfaceElement element) {
  if (element.name != 'Result') return false;

  return element.library.uri.path.endsWith('utils/result.dart');
}
