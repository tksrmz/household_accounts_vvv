import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import 'calendar_view_model.dart';
import 'widgets/month_calendar.dart';
import 'widgets/month_header.dart';

/// 月次カレンダー画面。
///
/// シェル(タブ)の本体として表示されるため、Scaffoldは持たない。
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, required CalendarViewModel viewModel})
    : _viewModel = viewModel;

  final CalendarViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final summaries = _viewModel.dailySummaries;

        return ListView(
          children: [
            // ヘッダは読み込み中も失敗中も表示し続ける。月の切り替えは
            // カレンダーの表示状態によらず行えるべきで、失敗した月から
            // 別の月へ移ることが復帰手段にもなるため。
            MonthHeader(
              year: _viewModel.year,
              month: _viewModel.month,
              onPreviousMonthPressed: _viewModel.showPreviousMonth,
              onNextMonthPressed: _viewModel.canShowNextMonth
                  ? _viewModel.showNextMonth
                  : null,
            ),
            if (_viewModel.recordsError != null)
              const Center(child: _ErrorMessage())
            else if (summaries == null)
              const Center(child: CircularProgressIndicator())
            else
              MonthCalendar(
                year: _viewModel.year,
                month: _viewModel.month,
                dailySummaries: summaries,
                onDaySelected: (day) => context.push(
                  Routes.calendarDayOf(_viewModel.year, _viewModel.month, day),
                ),
              ),
          ],
        );
      },
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
