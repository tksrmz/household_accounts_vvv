import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/model/budget_graph_data.dart';
import 'package:household_accounts/presentation/dashboard/model/budget_graph_data_list.dart';
import 'package:household_accounts/presentation/dashboard/model/summary.dart';
import 'package:household_accounts/presentation/dashboard/page.dart';
import 'package:household_accounts/presentation/dashboard/view_model.dart';
import 'package:household_accounts/presentation/dashboard/vo/budget_name.dart';
import 'package:household_accounts/presentation/dashboard/widget/budget_graph.dart';
import 'package:household_accounts/presentation/dashboard/widget/summary_panel.dart';
import 'package:household_accounts/vo/budget_amount.dart';
import 'package:household_accounts/vo/budget_spent.dart';
import 'package:mockito/annotations.dart';

import '../../util/golden_helper.dart';
// Fakeクラス用にModelのモックも作る
@GenerateNiceMocks([MockSpec<SummaryModel>(), MockSpec<BudgetGraphModel>()])
import 'page_test.mocks.dart';

// テストケースは状態遷移テストで設計
void main() {
  /**
   * TODO
   *
   * - income.dartをentityディレクトリからvoディレクトリに移動する
   *   - expense.dartも？
   * - main_pageでViewModelをインスタンス化するのはいい？
   * - エラーのときはViewModelからModelを取り出せなくする
   * - 発生したエラーに応じてエラーメッセージの内容を変える？
   * - ModelViewのテストで、ModelをisNotNullで検証するのをやめる
   * - ModelViewで2回以上init()が呼び出されても、2回目は何もしない
   * - ViewModelのincomeとexpenseを一つのプロパティ（summaryとか）にまとめる？
   * - 例外が発生したときにログを出力する？
   * - BudgetGraphModel.fetchでBudgetGraphDataListを取得できる
   * - personal modeとpair modeに対応する
   * - incomeRepositoryがLocalhostのFirebaseFirestoreと接続できるようにする（mockを使わずにrepositoryのテストをする）
   *   - これはIntegrationTestかE2Eテストの範囲な気がする
   *   - 範囲外のレコードを取得しないかテストする
   *   - 該当のレコードがないとき、0個取得する
   *   - 該当のレコードがただ1つあるとき、1個取得する
   * - expenseRepositoryがLocalhostのFirebaseFirestoreと接続できるようにする（mockを使わずにrepositoryのテストをする）
   *   - 範囲外のレコードを取得しないかテストする
   *   - 該当のレコードがないとき、0個取得する
   *   - 該当のレコードがただ1つあるとき、1個取得する
   * - 3. IntegrationTestでIncomeRepositoryをテストする
   * - エラー表示のときをエラーっぽい画面にする
   * - ローディング中の表示を確認する
   * - dateをX月1日00:00:00に整形するロジックをモデルに移す
   * - SummaryViewModelでデータがpublicアクセスかつnon finalになっているので保護する
   */
  testWidgets('init()呼び出し前はローディング中の表示がされる', (tester) async {
    final fakeViewModel = FakeSummaryViewModelLoading();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardPage(
          date: DateTime(2025, 1),
          viewModel: fakeViewModel,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SummaryPanel), findsNothing);
    expect(find.byType(BudgetGraph), findsNothing);
  });

  testGoldens(
    'init()呼び出し前はローディング中の表示がされる',
    builder: () => DashboardPage(
      date: DateTime(2025, 1),
      viewModel: FakeSummaryViewModelLoading(),
    ),
    goldenFileName: 'dashboard_page_loading',
  );

  testWidgets(
    'init()呼び出し後、初期化が完了していればダッシュボードコンテンツが表示される',
    (tester) async {
      final fakeViewModel = FakeSummaryViewModelComplete();

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(
            date: DateTime(2025, 1),
            viewModel: fakeViewModel,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SummaryPanel), findsOneWidget);
      expect(find.byType(BudgetGraph), findsOneWidget);
    },
  );

  testGoldens(
    'init()呼び出し後、初期化が完了していればダッシュボードコンテンツが表示される',
    builder: () => DashboardPage(
      date: DateTime(2025, 1),
      viewModel: FakeSummaryViewModelComplete(),
    ),
    goldenFileName: 'dashboard_page_complete',
  );

  testWidgets(
    'init()呼び出し後、エラーならエラーメッセージが表示される',
    (tester) async {
      final fakeViewModel = FakeSummaryViewModelError();

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(
            date: DateTime(2025, 1),
            viewModel: fakeViewModel,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('エラーが発生しました。時間をおいて再度お試しください。'), findsOneWidget);
    },
  );

  testGoldens(
    'init()呼び出し後、エラーならエラーメッセージが表示される',
    builder: () => DashboardPage(
      date: DateTime(2025, 1),
      viewModel: FakeSummaryViewModelError(),
    ),
    goldenFileName: 'dashboard_page_error',
  );

  testWidgets('ロードが正常に完了すると、ダッシュボードコンテンツが表示される', (tester) async {
    // それぞれの段階での画面キャプチャ→ゴールデンテスト
    // mockと期待通りのインタラクションをしていることの確認

    // fail!!!
    expect(1, 2);
  });

  testWidgets('ロードで異常が発生すると、エラー画面が表示される', (tester) async {
    // fail!!!
    expect(1, 2);
  });
}

class FakeSummaryViewModelLoading extends SummaryViewModel {
  FakeSummaryViewModelLoading()
      : super(
          summaryModel: MockSummaryModel(),
          budgetGraphModel: MockBudgetGraphModel(),
        );

  @override
  bool get isNotInitialized => true;

  @override
  Future<void> init(DateTime date) async {}
}

class FakeSummaryViewModelComplete extends SummaryViewModel {
  FakeSummaryViewModelComplete()
      : super(
          summaryModel: MockSummaryModel(),
          budgetGraphModel: MockBudgetGraphModel(),
        );

  @override
  Income get income => Income(100);

  @override
  Expense get expense => Expense(200);

  @override
  BudgetGraphDataList get budgetGraphDataList => BudgetGraphDataList([
        BudgetGraphData(
          name: BudgetName('食費'),
          budget: BudgetAmount(2000),
          spent: BudgetSpent(1000),
        ),
      ]);

  bool isNotInitializedFake = true;

  @override
  bool get isNotInitialized => isNotInitializedFake;

  @override
  Future<void> init(DateTime date) async {
    isNotInitializedFake = false;
    notifyListeners();
  }
}

class FakeSummaryViewModelError extends SummaryViewModel {
  FakeSummaryViewModelError()
      : super(
          summaryModel: MockSummaryModel(),
          budgetGraphModel: MockBudgetGraphModel(),
        );

  bool isNotInitializedFake = true;

  @override
  bool get isNotInitialized => isNotInitializedFake;

  @override
  bool get hasError => true;

  @override
  Future<void> init(DateTime date) async {
    isNotInitializedFake = false;
    notifyListeners();
  }
}
