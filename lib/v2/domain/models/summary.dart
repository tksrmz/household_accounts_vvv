import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/expense.dart';
import 'vo/income.dart';

part 'summary.freezed.dart';

@freezed
abstract class SummaryModel with _$SummaryModel {
  const factory SummaryModel(IncomeVo income, ExpenseVo expense) =
      _SummaryModel;
}
