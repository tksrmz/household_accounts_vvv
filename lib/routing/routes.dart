/// go_routerで使用するパス定数。
abstract final class Routes {
  static const signIn = '/sign-in';
  static const dashboard = '/dashboard';
  static const entry = '/entry';
  static const calendar = '/calendar';

  /// 日次明細のパス。`:date` は `yyyy-MM-dd`(ゼロ埋め)で与える。
  static const calendarDay = '$calendar/:date';

  /// [calendarDay] へ遷移するためのパスを組み立てる。
  static String calendarDayOf(int year, int month, int day) {
    final paddedMonth = month.toString().padLeft(2, '0');
    final paddedDay = day.toString().padLeft(2, '0');
    return '$calendar/$year-$paddedMonth-$paddedDay';
  }

  static const properties = '/properties';

  /// 資産の追加画面のパス。
  static const propertyNew = '$properties/new';

  /// 資産の編集画面のパス。編集対象の資産は `extra` で渡す。
  static const propertyEdit = '$properties/edit';

  static const categories = '/categories';
  static const budget = '/budget';
  static const settings = '/settings';
}
