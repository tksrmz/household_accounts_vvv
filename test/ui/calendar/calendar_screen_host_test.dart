import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/data/repositories/record/record_repository.dart';
import 'package:household_accounts/ui/calendar/calendar_screen_host.dart';
import 'package:provider/provider.dart';

import '../../test-util/fake_record_repository.dart';

void main() {
  testWidgets('アプリ復帰時に月をまたいでいたとき、翌月へ進む矢印が有効になること', (tester) async {
    var today = DateTime(2026, 8, 31);
    final recordRepository = FakeRecordRepository();
    await tester.pumpWidget(
      Provider<RecordRepository>.value(
        value: recordRepository,
        child: MaterialApp(home: CalendarScreenHost(now: () => today)),
      ),
    );
    recordRepository.recordsController.add(const []);
    await tester.pump();
    expect(_nextMonthButton(tester).onPressed, isNull);

    today = DateTime(2026, 9, 1);
    // 復帰は一度非アクティブを挟んで発生するため、遷移として送る
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(_nextMonthButton(tester).onPressed, isNotNull);
  });
}

IconButton _nextMonthButton(WidgetTester tester) => tester.widget<IconButton>(
  find.widgetWithIcon(IconButton, Icons.arrow_right),
);
