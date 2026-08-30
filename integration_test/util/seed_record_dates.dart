import 'firestore_rest.dart';

/// Firestoreエミュレータへimport済みのseedレコード(saved-data)の日付を、
/// テスト実行時の「今月」(実行端末のローカルタイムゾーン)の月境界へ揃える。
///
/// なぜ実行時に書き換えるか:
/// saved-dataのレコード日付は固定値である一方、ダッシュボードは実行時の
/// [DateTime.now]が属する暦月(端末ローカルTZ)で集計するため、そのままでは
/// 月が替わるたび・実行端末のタイムゾーンが変わるたびにテストが壊れる。
///
/// なぜUI操作で書き換えないか:
/// - 共有ノートのseedレコードはペアユーザーのダッシュボード検証に必要だが、
///   既存レコードの日付を編集するUIは存在しない
/// - 記録入力の日付ピッカーは時刻を指定できず、月境界(月末23:59:59等)の
///   フィクスチャを再現できない
///
/// そのためFirestoreエミュレータのREST API([FirestoreRest])を直接使用する。

/// saved-data内でレコードを持つノートのドキュメントパス。
/// - personalNotes: single_user@example.com のuid
/// - sharedNotes: pair_user_a/b@example.com が共有するノート
const _seedNotePaths = [
  'personalNotes/fmVfCNkA2wGfJx69LRFhl3ird9EB',
  'sharedNotes/fQXxUXlNqXLIQx80TsEd',
];

const _recordCollections = ['incomes', 'expenses', 'transfers'];

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
  await useFirestoreRest((rest) async {
    for (final notePath in _seedNotePaths) {
      for (final collection in _recordCollections) {
        final documents = await rest.listDocuments('$notePath/$collection');
        for (final document in documents) {
          final note = tryReadString(fieldsOf(document), 'note');
          final newDate = boundaries[note];
          if (newDate == null) {
            continue;
          }
          // dateだけを更新し、他フィールドは保持する
          await rest.patchDocument(
            documentPathOf(document['name'] as String),
            fields: {'date': timestampValue(newDate)},
            updateMaskFieldPaths: const ['date'],
          );
        }
      }
    }
  });
}
