import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../entity/expense.dart';
import '../../../entity/income.dart';

part 'summary.freezed.dart';

class SummaryModel {
  /// 当該月の収支データを取得する
  ///
  /// [date] 取得対象の年月
  Future<Summary> fetch(DateTime date) async {
    throw UnimplementedError();
  }
}

class Summary {
  const Summary(this.income, this.expense);

  final Income income;
  final Expense expense;
}

/// SummaryModelでエラーが発生したときにスローされる例外
@freezed
class SummaryModelException with _$SummaryModelException implements Exception {
  @Assert('message.length > 0', 'エラーメッセージが空です')
  const factory SummaryModelException(String message) = _SummaryModelException;
}
