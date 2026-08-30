import 'property_id.dart';

/// レコードが資産残高に与える単一の増減。
///
/// 資産の残高はレコードから独立した値ではなく、レコードの集合から導出される
/// 派生値である、というルールをこの型で定義する。[NewRecord.balanceEffects]が
/// レコード種別ごとの増減内容(振替は2件、収入/支出は1件)を組み立てる際の
/// 要素として使う。
typedef BalanceEffect = ({PropertyId propertyId, int delta});
