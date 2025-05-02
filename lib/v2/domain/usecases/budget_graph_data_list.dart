import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../vo/budget_amount.dart';
import '../../../vo/budget_spent.dart';
import '../models/budget_graph_data.dart';

part 'budget_graph_data_list.freezed.dart';

class BudgetGraphModel {
  /// 予算のグラフデータを取得する
  ///
  /// [date] 取得対象の年月
  Future<BudgetGraphDataList> fetch(DateTime date) async {
    throw UnimplementedError();
  }
}

class BudgetGraphDataList extends Equatable {
  final List<BudgetGraphData> _list;

  const BudgetGraphDataList(this._list);

  UnmodifiableListView<BudgetGraphData> get list => UnmodifiableListView(_list);

  /// 予算の設定が存在しない
  ///
  /// 予算が1つも設定されていない場合にtrueを返す。
  /// 「0円の予算があるか」ということではなく、予算の設定それ自体が存在しないかどうかを判定する。
  bool get isNotBudgetConfigured => _list.isEmpty;

  /// 予算の設定が存在する
  bool get isBudgetConfigured => !isNotBudgetConfigured;

  /// 予算の合計値を取得する
  BudgetAmount get totalBudget => BudgetAmount.sum(
        _list.map((item) => item.budget).toList(),
      );

  /// 使用している予算だけを抜き出したリストへ変換する
  BudgetGraphDataList toListWhereBudgetIsSpent() {
    return BudgetGraphDataList(
      _list.where((item) => item.spent.isUsed).toList(),
    );
  }

  /// 総予算に対する使用額の割合の降順でソートされたリストを取得する
  BudgetGraphDataList sortBySpentRatio() {
    return BudgetGraphDataList(
      _list
        ..sort((a, b) {
          final aRatio = a.spent.value / totalBudget.value;
          final bRatio = b.spent.value / totalBudget.value;
          return bRatio.compareTo(aRatio);
        }),
    );
  }

  /// 予算の使用額のリストへ変換する
  UnmodifiableListView<BudgetSpent> toBudgetSpentList() {
    return UnmodifiableListView(_list.map((item) => item.spent).toList());
  }

  @override
  List<Object?> get props => [_list];

  @override
  bool get stringify => true;
}

/// BudgetGraphListの例外
@freezed
abstract class BudgetGraphModelException
    with _$BudgetGraphModelException
    implements Exception {
  const factory BudgetGraphModelException(String message) =
      _BudgetGraphModelException;
}
