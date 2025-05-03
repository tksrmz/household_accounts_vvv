import 'package:freezed_annotation/freezed_annotation.dart';

import 'vo/expense.dart';
import 'vo/income.dart';
import 'vo/user_name.dart';

part 'dashboard_info.freezed.dart';

@freezed
abstract class DashboardInfoModel with _$DashboardInfoModel {
  const factory DashboardInfoModel(
    IncomeVo income,
    ExpenseVo expense, [
    @Default(const UserNameVo("hoge")) UserNameVo userName,
  ]) = _DashboardInfoModel;
}
