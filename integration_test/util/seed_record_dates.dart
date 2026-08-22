import 'dart:convert';
import 'dart:io';

/// Firestoreエミュレータへimport済みのseedレコード(saved-data)の日付を、
/// テスト実行時の「今月」(実行端末のローカルタイムゾーン)の月境界へ揃える。
///
/// なぜ実行時に書き換えるか:
/// saved-dataのレコード日付は固定値である一方、ダッシュボードは実行時の
/// [DateTime.now]が属する暦月(端末ローカルTZ)で集計するため、そのままでは
/// 月が替わるたび・実行端末のタイムゾーンが変わるたびにテストが壊れる。
///
/// なぜUI操作でseedしないか(record_seeding.dartの方針の例外):
/// - 共有ノートへの記録入力UIは現行アーキテクチャには存在せず、ペアユーザーの
///   ダッシュボード検証に必要な共有ノートのレコードをUIから投入できない
/// - 記録入力の日付ピッカーは時刻を指定できず、月境界(月末23:59:59等)の
///   フィクスチャを再現できない
///
/// そのためFirestoreエミュレータのREST APIを直接使用する。
/// `Authorization: Bearer owner` はエミュレータ専用の特権トークンで、
/// セキュリティルールを適用せずに読み書きできる。
/// (integration_testの[IntegrationTestWidgetsFlutterBinding]は
/// flutter_testと異なりHttpClientをモックしないため、実HTTPを送信できる)

/// saved-data内でレコードを持つノートのドキュメントパス。
/// - personalNotes: single_user@example.com のuid
/// - sharedNotes: pair_user_a/b@example.com が共有するノート
const _seedNotePaths = [
  'personalNotes/fmVfCNkA2wGfJx69LRFhl3ird9EB',
  'sharedNotes/fQXxUXlNqXLIQx80TsEd',
];

const _recordCollections = ['incomes', 'expenses', 'transfers'];

/// lib/firebase_options.dart と同一のプロジェクトIDであること
/// (emulators:exec の --project 指定とも一致する必要がある)
const _projectId = 'household-accounts-1129d';

/// firebase/firebase.json のFirestoreエミュレータポートと同期を保つこと
const _firestorePort = 8081;

/// FlutterFireプラグインはAndroidで'localhost'を10.0.2.2へ自動変換するが、
/// dart:ioの生HTTPでは自前でホストマシンのループバックへ向ける必要がある
final _host = Platform.isAndroid ? '10.0.2.2' : 'localhost';

/// seedレコードのnoteフィールドは、そのレコードが検証する月境界の
/// セマンティクスを表す。実行時の「今月」の境界日時へ写像する:
/// - date下限値: 月初00:00(集計対象)
/// - date下限値超え: 前月末23:59:59(集計対象外)
/// - date上限値: 月末23:59:59(集計対象)
/// - date上限値超え: 翌月初00:00(集計対象外)
Map<String, DateTime> _boundaryDatesOfCurrentMonth() {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final nextMonthStart = DateTime(now.year, now.month + 1);
  return {
    'date下限値': monthStart,
    'date下限値超え': monthStart.subtract(const Duration(seconds: 1)),
    'date上限値': nextMonthStart.subtract(const Duration(seconds: 1)),
    'date上限値超え': nextMonthStart,
  };
}

/// seedレコード全件のdateフィールドを実行時の「今月」の境界日時へ書き換える。
///
/// noteフィールドが境界セマンティクス([_boundaryDatesOfCurrentMonth]のキー)に
/// 一致しないレコードは対象外としてスキップする。
/// 冪等であり、テストごとに何度呼び出してもよい。
Future<void> alignSeedRecordDatesToCurrentMonth() async {
  final boundaries = _boundaryDatesOfCurrentMonth();
  final client = HttpClient();
  try {
    for (final notePath in _seedNotePaths) {
      for (final collection in _recordCollections) {
        final documents = await _listDocuments(client, '$notePath/$collection');
        for (final document in documents) {
          final fields = document['fields'] as Map<String, dynamic>? ?? {};
          final note =
              (fields['note'] as Map<String, dynamic>?)?['stringValue']
                  as String?;
          final newDate = boundaries[note];
          if (newDate == null) {
            continue;
          }
          await _updateDate(client, document['name'] as String, newDate);
        }
      }
    }
  } finally {
    client.close(force: true);
  }
}

/// 指定コレクション直下のドキュメント一覧を取得する。
/// コレクションが存在しない場合は空リストを返す。
Future<List<Map<String, dynamic>>> _listDocuments(
  HttpClient client,
  String collectionPath,
) async {
  final uri = Uri.http(
    '$_host:$_firestorePort',
    '/v1/projects/$_projectId/databases/(default)/documents/$collectionPath',
    {'pageSize': '300'},
  );
  final request = await client.getUrl(uri);
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
  final body = await _readResponse(request, uri);
  final documents =
      (jsonDecode(body) as Map<String, dynamic>)['documents'] as List<dynamic>?;
  return documents?.cast<Map<String, dynamic>>() ?? [];
}

/// ドキュメントのdateフィールドのみを更新する(updateMaskで他フィールドは保持)。
Future<void> _updateDate(
  HttpClient client,
  String documentName,
  DateTime date,
) async {
  final uri = Uri.http('$_host:$_firestorePort', '/v1/$documentName', {
    'updateMask.fieldPaths': 'date',
  });
  final request = await client.patchUrl(uri);
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
  request.headers.contentType = ContentType.json;
  request.write(
    jsonEncode({
      'fields': {
        'date': {'timestampValue': date.toUtc().toIso8601String()},
      },
    }),
  );
  await _readResponse(request, uri);
}

Future<String> _readResponse(HttpClientRequest request, Uri uri) async {
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
