import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_accounts/util/extension/date_time.dart';

extension QueryUtil<T> on CollectionReference<T> {
  Query<T> whereInThisMonth(
    String field,
    DateTime date,
  ) {
    final firstDayOfMonth = date.toFirstDayOfMonth();
    return where(
      field,
      isGreaterThanOrEqualTo: firstDayOfMonth,
      isLessThan: firstDayOfMonth.nextMonth(),
    );
  }
}
