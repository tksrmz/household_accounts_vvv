import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_rest.dart';

/// integrationテストのアサーション用に、Firestoreへ実際に書き込まれた内容を
/// 読み取るためのヘルパー群。
///
/// なぜアプリのRepositoryを使わずREST APIで読むか:
/// 書き込みと読み取りが同じ変換コードを通ると、その変換が誤っていても
/// 往復では辻褄が合ってしまい検証にならない。保存先のパス・フィールド名・
/// 値の形そのものを、アプリの外側から確認する。

/// 現在サインイン中のユーザーの個人ノートのドキュメントパス。
String currentPersonalNotePath() => 'personalNotes/${_currentUid()}';

/// 現在サインイン中のユーザーが属する共有ノートのドキュメントパス。
///
/// アプリと同じ経路(privateProfiles/{uid} の sharedNote.ref)でpairIdを解決する。
Future<String> currentSharedNotePath() async {
  final uid = _currentUid();
  final profile = await useFirestoreRest(
    (rest) => rest.getDocument('privateProfiles/$uid'),
  );
  final sharedNote = readMap(fieldsOf(profile), 'sharedNote');
  return readReferencePath(sharedNote, 'ref');
}

/// [note]が一致するレコードのフィールドを返す。
///
/// 1件に絞れないときは[StateError]を送出する(0件=書き込まれていない、
/// 複数件=テストのnoteが一意でない、のどちらもテストの失敗として扱う)。
Future<Map<String, dynamic>> fetchRecordByNote(
  String notePath,
  String collection,
  String note,
) async => fieldsOf(
  await _singleDocumentByField('$notePath/$collection', 'note', note),
);

/// [note]が一致するレコードの件数。書き込み先が正しいこと(誤ったノートへ
/// 書かれていないこと)を確認するために使う。
Future<int> countRecordsByNote(
  String notePath,
  String collection,
  String note,
) async {
  final documents = await useFirestoreRest(
    (rest) => rest.listDocuments('$notePath/$collection'),
  );
  return documents
      .where((document) => tryReadString(fieldsOf(document), 'note') == note)
      .length;
}

/// 資産[propertyName]の現在の残高。
Future<int> fetchPropertyAmount(String notePath, String propertyName) async {
  final document = await _singleDocumentByField(
    '$notePath/properties',
    'name',
    propertyName,
  );
  return readInt(fieldsOf(document), 'amount');
}

/// `name`が[propertyName]である資産の件数。
///
/// 資産のドキュメントが消えたこと(削除)や、誤ったノートへ書かれていないこと
/// (共有ノートでの操作)を確認するために使う。
Future<int> countPropertiesByName(String notePath, String propertyName) =>
    countDocumentsByName('$notePath/properties', propertyName);

/// [collectionPath]のうち、`name`が[name]であるドキュメントのフィールドを返す。
///
/// 名前で識別できるドキュメント(カテゴリ・資産)の保存内容を確認するために使う。
/// 1件に絞れないときは[StateError]を送出する。
Future<Map<String, dynamic>> fetchFieldsByName(
  String collectionPath,
  String name,
) async => fieldsOf(await _singleDocumentByField(collectionPath, 'name', name));

/// [collectionPath]のうち、`name`が[name]であるドキュメントの件数。
///
/// ドキュメントが消えたこと(削除)や、誤ったノートへ書かれていないこと
/// (共有ノートでの操作)を確認するために使う。
Future<int> countDocumentsByName(String collectionPath, String name) async {
  final documents = await useFirestoreRest(
    (rest) => rest.listDocuments(collectionPath),
  );
  return documents
      .where((document) => tryReadString(fieldsOf(document), 'name') == name)
      .length;
}

/// `name`が[name]であるドキュメントのパスを返す。
///
/// レコードの参照フィールド(category.ref等)が、名前で識別できる
/// カテゴリ・資産を指していることを確認するために使う。
Future<String> fetchDocumentPathByName(
  String collectionPath,
  String name,
) async => documentPathOf(
  (await _singleDocumentByField(collectionPath, 'name', name))['name']
      as String,
);

/// [field]の文字列が[value]と一致するドキュメントをちょうど1件返す。
///
/// エミュレータのREST APIはクエリ(runQuery)も持つが、1コレクションあたりの
/// 件数がテストデータの規模に収まるため、一覧取得してDart側で絞る。
Future<Map<String, dynamic>> _singleDocumentByField(
  String collectionPath,
  String field,
  String value,
) async {
  final documents = await useFirestoreRest(
    (rest) => rest.listDocuments(collectionPath),
  );
  final matched = documents
      .where((document) => tryReadString(fieldsOf(document), field) == value)
      .toList();
  if (matched.length != 1) {
    throw StateError(
      '$collectionPath に $field="$value" のドキュメントが'
      '${matched.length}件見つかりました(期待: 1件)',
    );
  }
  return matched.single;
}

String _currentUid() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw StateError('サインインしていないため、ノートのパスを解決できません');
  }
  return user.uid;
}
