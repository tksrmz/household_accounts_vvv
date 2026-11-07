import 'package:flutter/material.dart';

import '../../domain/models/budget_summary.dart';
import '../../domain/models/period.dart';
import 'budget_view_model.dart';
import 'widgets/budget_row.dart';
import 'widgets/period_header.dart';

/// 予算画面。期間を選び、支出カテゴリごとの予算の消化状況を一覧する。
///
/// シェル(タブ)の本体として表示されるため、Scaffoldは持たない。
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key, required BudgetViewModel viewModel})
    : _viewModel = viewModel;

  final BudgetViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SegmentedButton<BudgetPeriodMode>(
                segments: const [
                  ButtonSegment(
                    value: BudgetPeriodMode.calendarMonth,
                    label: Text('暦月'),
                  ),
                  ButtonSegment(
                    value: BudgetPeriodMode.fiscalMonth,
                    label: Text('月度'),
                  ),
                ],
                selected: {_viewModel.mode},
                onSelectionChanged: (selected) =>
                    _viewModel.selectMode(selected.single),
              ),
            ),
            // 期間の切り替えは一覧の表示状態によらず行えるべきで、失敗した
            // 期間から別の期間へ移ることが復帰手段にもなるため、読み込み中も
            // 失敗中もヘッダを表示し続ける
            PeriodHeader(
              label: _periodLabel(
                _viewModel.mode,
                _viewModel.year,
                _viewModel.month,
                _viewModel.period,
              ),
              onPreviousPressed: _viewModel.showPrevious,
              onNextPressed: _viewModel.canShowNext
                  ? _viewModel.showNext
                  : null,
            ),
            Expanded(child: _body()),
          ],
        );
      },
    );
  }

  Widget _body() {
    if (_viewModel.loadError != null) {
      return const Center(child: _ErrorMessage());
    }
    final summary = _viewModel.summary;
    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _BudgetList(summary: summary);
  }

  /// 期間のラベル(暦月「2026年7月（7/1〜7/31）」、月度「2026年7月度（6/16〜7/15）」)。
  ///
  /// 期間の終了([Period.end])は含まない境界なので、表示する最終日はその前日
  /// になる。日数の差を[Duration]で引くと夏時間のある地域で日付がずれうるため、
  /// 日の値を1つ戻した[DateTime]で求める。
  static String _periodLabel(
    BudgetPeriodMode mode,
    int year,
    int month,
    Period period,
  ) {
    final start = period.start;
    final end = period.end;
    final lastDay = DateTime(end.year, end.month, end.day - 1);
    final name = switch (mode) {
      BudgetPeriodMode.calendarMonth => '$year年$month月',
      BudgetPeriodMode.fiscalMonth => '$year年$month月度',
    };
    return '$name（${start.month}/${start.day}〜${lastDay.month}/${lastDay.day}）';
  }
}

/// 支出カテゴリごとの予算の消化状況の一覧。
class _BudgetList extends StatelessWidget {
  const _BudgetList({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final (:category, :spent) in summary.categories)
        BudgetRow(
          name: category.name.value,
          spent: spent,
          budget: category.budget.value,
        ),
      // 削除されたカテゴリを参照する支出は、それがあるときだけ末尾に1行で出す。
      // 予算を持つカテゴリはもう無いため、予算0の行として描く
      if (summary.orphanedExpense > 0)
        BudgetRow(name: '削除済み', spent: summary.orphanedExpense, budget: 0),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
      separatorBuilder: (context, index) => const Divider(color: Colors.black),
    );
  }
}

/// 読み込みに失敗したことを伝える表示。
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.error,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16.0),
          const Text('エラーが発生しました。'),
          const SizedBox(height: 8.0),
          const Text('アプリを再起動してください。'),
        ],
      ),
    );
  }
}
