import 'dart:convert';
import 'dart:io';

/// FirestoreエミュレータのREST APIを直接叩くための低レベルヘルパー。
///
/// なぜ生HTTPを使うか:
/// - シードには、UI操作では作れない値(未来日付・時刻付きの月境界)が必要になる
/// - 検証では、アプリが実際に書いたドキュメントをアプリのコードを介さずに
///   読み取りたい(アプリ側の変換バグを検証が一緒に見逃さないため)
///
/// `Authorization: Bearer owner` はエミュレータ専用の特権トークンで、
/// セキュリティルールを適用せずに読み書きできる。
/// (integration_testの`IntegrationTestWidgetsFlutterBinding`は
/// flutter_testと異なりHttpClientをモックしないため、実HTTPを送信できる)

/// lib/firebase_options.dart と同一のプロジェクトIDであること
/// (emulators:exec の --project 指定とも一致する必要がある)
const firestoreProjectId = 'household-accounts-1129d';

/// firebase/firebase.json のFirestoreエミュレータポートと同期を保つこと
const firestorePort = 8081;

/// FlutterFireプラグインはAndroidで'localhost'を10.0.2.2へ自動変換するが、
/// dart:ioの生HTTPでは自前でホストマシンのループバックへ向ける必要がある
final firestoreHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';

/// REST APIがドキュメントの完全修飾名(`name`・`referenceValue`)に用いる接頭辞。
const firestoreDocumentsRoot =
    'projects/$firestoreProjectId/databases/(default)/documents';

/// [body]の実行中だけHTTP接続を開き、終了時に必ず閉じる。
Future<T> useFirestoreRest<T>(
  Future<T> Function(FirestoreRest rest) body,
) async {
  final rest = FirestoreRest();
  try {
    return await body(rest);
  } finally {
    rest.close();
  }
}

/// FirestoreエミュレータのREST APIクライアント。
///
/// 1回のシード投入で数十リクエストを送るため、HTTP接続を使い回せるよう
/// クライアントをフィールドで保持する。使い終えたら[close]すること
/// (通常は[useFirestoreRest]経由で使う)。
class FirestoreRest {
  FirestoreRest() : _client = HttpClient();

  final HttpClient _client;

  /// 指定コレクション直下のドキュメント一覧を取得する。
  /// コレクションが存在しない場合は空リストを返す。
  Future<List<Map<String, dynamic>>> listDocuments(
    String collectionPath,
  ) async {
    final uri = _uri(collectionPath, {'pageSize': '300'});
    final request = await _client.getUrl(uri);
    final body = await _send(request, uri);
    final documents =
        (jsonDecode(body) as Map<String, dynamic>)['documents']
            as List<dynamic>?;
    return documents?.cast<Map<String, dynamic>>() ?? [];
  }

  /// 単一ドキュメントを取得する。存在しない場合は[StateError]を送出する。
  Future<Map<String, dynamic>> getDocument(String documentPath) async {
    final uri = _uri(documentPath, const {});
    final request = await _client.getUrl(uri);
    final body = await _send(request, uri);
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// ドキュメントの一部フィールドだけを更新する。
  ///
  /// [updateMaskFieldPaths]に挙げたフィールド以外は書き換えない。
  Future<void> patchDocument(
    String documentPath, {
    required Map<String, Object?> fields,
    required List<String> updateMaskFieldPaths,
  }) async {
    final uri = _uri(documentPath, {
      'updateMask.fieldPaths': updateMaskFieldPaths,
    });
    final request = await _client.patchUrl(uri);
    await _send(request, uri, payload: {'fields': fields});
  }

  /// コレクションへドキュメントを1件追加する(IDは自動採番)。
  ///
  /// 作成されたドキュメント(REST表現)を返す。
  Future<Map<String, dynamic>> createDocument(
    String collectionPath,
    Map<String, Object?> fields,
  ) async {
    final uri = _uri(collectionPath, const {});
    final request = await _client.postUrl(uri);
    final body = await _send(request, uri, payload: {'fields': fields});
    return jsonDecode(body) as Map<String, dynamic>;
  }

  void close() => _client.close(force: true);

  Uri _uri(String path, Map<String, dynamic> query) => Uri.http(
    '$firestoreHost:$firestorePort',
    '/v1/$firestoreDocumentsRoot/$path',
    query.isEmpty ? null : query,
  );

  Future<String> _send(
    HttpClientRequest request,
    Uri uri, {
    Map<String, Object?>? payload,
  }) async {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
    if (payload != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
    }
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != HttpStatus.ok) {
      throw StateError(
        'Firestoreエミュレータへのリクエストに失敗しました: '
        '${request.method} $uri -> ${response.statusCode} $body',
      );
    }
    return body;
  }
}

/// ドキュメントの完全修飾名(`projects/.../documents/xxx/yyy`)から、
/// このヘルパーが扱う相対パス(`xxx/yyy`)を取り出す。
String documentPathOf(String resourceName) {
  const prefix = '$firestoreDocumentsRoot/';
  if (!resourceName.startsWith(prefix)) {
    throw StateError('想定外のドキュメント名です: $resourceName');
  }
  return resourceName.substring(prefix.length);
}

/// REST表現のドキュメントからフィールドの集合を取り出す。
/// フィールドを1つも持たないドキュメントでは`fields`自体が省略される。
Map<String, dynamic> fieldsOf(Map<String, dynamic> document) =>
    document['fields'] as Map<String, dynamic>? ?? const {};

// 値のエンコード。REST APIは型名をキーにしたラッパー
// (例: `{'integerValue': '100'}`)で値を表現する。

Map<String, Object?> stringValue(String value) => {'stringValue': value};

/// integerValueはREST上では文字列で表現される(JSONの数値は精度が足りないため)。
Map<String, Object?> integerValue(int value) => {'integerValue': '$value'};

Map<String, Object?> timestampValue(DateTime value) => {
  'timestampValue': value.toUtc().toIso8601String(),
};

/// [documentPath]は`personalNotes/{uid}/properties/{id}`のような相対パス。
Map<String, Object?> referenceValue(String documentPath) => {
  'referenceValue': '$firestoreDocumentsRoot/$documentPath',
};

Map<String, Object?> mapValue(Map<String, Object?> fields) => {
  'mapValue': {'fields': fields},
};

// 値のデコード。想定と違う形のときは、どのフィールドが原因かが分かる
// [StateError]にして落とす(テストの失敗理由を読めるようにするため)。

String readString(Map<String, dynamic> fields, String field) =>
    tryReadString(fields, field) ??
    (throw StateError('$field は文字列ではありません: ${fields[field]}'));

String? tryReadString(Map<String, dynamic> fields, String field) =>
    (fields[field] as Map<String, dynamic>?)?['stringValue'] as String?;

int readInt(Map<String, dynamic> fields, String field) {
  final value = (fields[field] as Map<String, dynamic>?)?['integerValue'];
  if (value is! String) {
    throw StateError('$field は整数ではありません: ${fields[field]}');
  }
  return int.parse(value);
}

/// タイムスタンプをUTCの[DateTime]として読み取る。
///
/// Firestoreは常にUTCで保持するため、ローカル時刻と比較する場合は
/// 呼び出し側で`toUtc()`を揃えること。
DateTime readTimestamp(Map<String, dynamic> fields, String field) {
  final value = (fields[field] as Map<String, dynamic>?)?['timestampValue'];
  if (value is! String) {
    throw StateError('$field はタイムスタンプではありません: ${fields[field]}');
  }
  return DateTime.parse(value).toUtc();
}

/// mapValue形のフィールドから、入れ子のフィールド集合を取り出す。
Map<String, dynamic> readMap(Map<String, dynamic> fields, String field) {
  final value = (fields[field] as Map<String, dynamic>?)?['mapValue'];
  if (value is! Map<String, dynamic>) {
    throw StateError('$field はマップではありません: ${fields[field]}');
  }
  return value['fields'] as Map<String, dynamic>? ?? const {};
}

/// 参照フィールドの指す先を、このヘルパーが扱う相対パスで返す。
String readReferencePath(Map<String, dynamic> fields, String field) {
  final value = (fields[field] as Map<String, dynamic>?)?['referenceValue'];
  if (value is! String) {
    throw StateError('$field は参照ではありません: ${fields[field]}');
  }
  return documentPathOf(value);
}
