import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/data/repositories/category/category_repository.dart';
import 'package:household_accounts/data/repositories/record/record_repository.dart';
import 'package:household_accounts/domain/models/budget.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/notebook.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/ui/budget/budget_screen_host.dart';
import 'package:provider/provider.dart';

import '../../test-util/fake_category_repository.dart';
import '../../test-util/fake_record_repository.dart';

final _personal = Notebook.personal(UserId('uid'));
final _shared = Notebook.shared(PairId('pair'));

void main() {
  testWidgets('ノートを切り替えたとき、切替前の購読が解除され、切替先のノートの暦月の当月が表示されること', (tester) async {
    final personal = _Repositories();
    final shared = _Repositories();

    await tester.pumpWidget(_app(_personal, personal));
    personal.emit([_category('個人の食費')]);
    await tester.pump();
    expect(find.text('個人の食費'), findsOneWidget);

    // 過去の月度を表示した状態から切り替え、表示の期間がリセットされることも見る
    await tester.tap(find.text('月度'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pump();

    // routerはノート切替でRepositoryとHostのキーを同時に差し替える
    await tester.pumpWidget(_app(_shared, shared));
    shared.emit([_category('共有の食費')]);
    await tester.pump();

    expect(personal.records.recordsController.hasListener, isFalse);
    expect(
      personal.categories.expenseCategoriesController.hasListener,
      isFalse,
    );
    expect(shared.records.watchedPeriods, [Period.calendarMonth(2026, 7)]);
    expect(shared.categories.watchExpenseCategoriesCallCount, 1);
    expect(find.text('個人の食費'), findsNothing);
    expect(find.text('共有の食費'), findsOneWidget);
  });

  testWidgets('アプリ復帰時に今日が属する期間をまたいでいたとき、次の期間へ進む矢印が有効になること', (tester) async {
    var today = DateTime(2026, 7, 31);
    final repositories = _Repositories();
    await tester.pumpWidget(_app(_personal, repositories, now: () => today));
    repositories.emit([]);
    await tester.pump();
    expect(_nextButton(tester).onPressed, isNull);

    today = DateTime(2026, 8, 1);
    // 復帰は一度非アクティブを挟んで発生するため、遷移として送る
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(_nextButton(tester).onPressed, isNotNull);
  });
}

class _Repositories {
  final records = FakeRecordRepository();
  final categories = FakeCategoryRepository();

  void emit(List<ExpenseCategory> expenseCategories) {
    categories.expenseCategoriesController.add(expenseCategories);
    records.recordsController.add(const []);
  }
}

/// routerの`_notebookScoped`と同じく、選択中ノートを`ValueKey`にしてHostを置く。
Widget _app(
  Notebook notebook,
  _Repositories repositories, {
  DateTime Function()? now,
}) {
  return MultiProvider(
    providers: [
      Provider<RecordRepository>.value(value: repositories.records),
      Provider<CategoryRepository>.value(value: repositories.categories),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: BudgetScreenHost(
          key: ValueKey(notebook),
          now: now ?? () => DateTime(2026, 7, 10),
        ),
      ),
    ),
  );
}

ExpenseCategory _category(String name) => ExpenseCategory(
  id: CategoryId(name),
  name: CategoryName(name),
  budget: Budget(30000),
);

IconButton _nextButton(WidgetTester tester) => tester.widget<IconButton>(
  find.widgetWithIcon(IconButton, Icons.arrow_right),
);
