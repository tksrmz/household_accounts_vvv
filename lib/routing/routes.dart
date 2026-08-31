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
  static const categories = '/categories';
  static const budget = '/budget';
  static const settings = '/settings';
}
