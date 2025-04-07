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
import 'package:mockito/mockito.dart';

import '../../util/golden_helper.dart';
// Fakeクラス用にModelのモックも作る
@GenerateNiceMocks([
  MockSpec<SummaryModel>(),
  MockSpec<BudgetGraphModel>(),
  MockSpec<SummaryViewModel>()
])
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
  late SummaryViewModel mockViewModel = MockSummaryViewModel();

  tearDown(() {
    // モックのクリーンアップ
    reset(mockViewModel);
  });

  group('初期化完了前はローディング画面が表示される', () {
    setUp(() {
      // モックの初期化
      when(mockViewModel.init(DateTime(2025, 1))).thenAnswer(
        (_) => Future.value(),
      );
      when(mockViewModel.isBeforeInitialization).thenReturn(true);
    });

    final targetBuilder = () => DashboardPage(
          date: DateTime(2025, 1),
          viewModel: mockViewModel,
        );

    testWidgets('初期化完了前はローディング画面が表示される', (tester) async {
      await tester.pumpWidget(MaterialApp(home: targetBuilder()));

      verify(mockViewModel.init(DateTime(2025, 1))).called(1);
      verify(mockViewModel.isBeforeInitialization).called(1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SummaryPanel), findsNothing);
      expect(find.byType(BudgetGraph), findsNothing);
    });

    testGoldens(
      '初期化完了前はローディング画面が表示される',
      builder: targetBuilder,
      goldenFileName: 'dashboard_page_loading',
    );
  });

  group('初期化が正常に完了するとダッシュボードコンテンツが表示される', () {
    setUp(() {
      // モックの初期化
      when(mockViewModel.isBeforeInitialization).thenReturn(false);
      when(mockViewModel.hasError).thenReturn(false);
      when(mockViewModel.income).thenReturn(Income(100));
      when(mockViewModel.expense).thenReturn(Expense(200));
      when(mockViewModel.budgetGraphDataList).thenReturn(
        BudgetGraphDataList([
          BudgetGraphData(
            name: BudgetName('食費'),
            budget: BudgetAmount(2000),
            spent: BudgetSpent(1000),
          ),
        ]),
      );
    });

    testWidgets(
      '初期化完了後にダッシュボードコンテンツが表示される',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DashboardPage(
              date: DateTime(2025, 1),
              viewModel: mockViewModel,
            ),
          ),
        );

        verify(mockViewModel.init(DateTime(2025, 1))).called(1);
        verify(mockViewModel.isBeforeInitialization)
            .called(greaterThanOrEqualTo(1));
        verify(mockViewModel.hasError).called(greaterThanOrEqualTo(1));
        verify(mockViewModel.income).called(greaterThanOrEqualTo(1));
        verify(mockViewModel.expense).called(greaterThanOrEqualTo(1));
        verify(mockViewModel.budgetGraphDataList)
            .called(greaterThanOrEqualTo(1));
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(SummaryPanel), findsOneWidget);
        expect(find.byType(BudgetGraph), findsOneWidget);
      },
    );

    testGoldens(
      '初期化完了後にダッシュボードコンテンツが表示される',
      builder: () => DashboardPage(
        date: DateTime(2025, 1),
        viewModel: mockViewModel,
      ),
      goldenFileName: 'dashboard_page_complete',
    );
  });

  group('初期化に失敗するとエラーメッセージが表示される', () {
    setUp(() {
      // モックの初期化
    });
    // skip for now
    // will be done in next sprint
  });

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
}

class FakeSummaryViewModelError extends SummaryViewModel {
  FakeSummaryViewModelError()
      : super(
          summaryModel: MockSummaryModel(),
          budgetGraphModel: MockBudgetGraphModel(),
        );

  bool isNotInitializedFake = true;

  @override
  bool get isBeforeInitialization => isNotInitializedFake;

  @override
  bool get hasError => true;

  @override
  Future<void> init(DateTime date) async {
    isNotInitializedFake = false;
    notifyListeners();
  }
}
