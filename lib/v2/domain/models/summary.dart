import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/expense.dart';
import 'vo/income.dart';

part 'summary.freezed.dart';

@freezed
class SummaryModel with _$SummaryModel {
  const factory SummaryModel(Income income, Expense expense) = _SummaryModel;
}
