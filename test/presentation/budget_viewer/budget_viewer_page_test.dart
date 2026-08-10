import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/feature/budget_analyzer/budget_analyzer_use_case.dart';
import 'package:household_accounts/feature/repository/category_repository.dart';
import 'package:household_accounts/feature/repository/record_repository.dart';
import 'package:household_accounts/presentation/budget_viewer/budget_viewer_page.dart';
import 'package:household_accounts/presentation/util/model/user_info.dart';
import 'package:household_accounts/util/service_locator/main.dart';
import 'package:household_accounts/v2/presentation/pages/state_managements/selected_note_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../test-util/golden_helper.dart';
@GenerateNiceMocks([
  MockSpec<RetrieveBudgetStateUseCase>(),
  MockSpec<PersonalExpenseRecordRepository>(),
  MockSpec<PersonalExpenseCategoryRepository>(),
  MockSpec<SharedExpenseRecordRepository>(),
  MockSpec<SharedExpenseCategoryRepository>(),
])
import 'budget_viewer_page_test.mocks.dart';

/// [targetBuilder] のデフォルトの「今日」（既存goldenテストが前提とする日付）。
DateTime _defaultNow() => DateTime(2026, 7, 1);

// NOTE: このテストは現行実装（暦月固定表示）に対するgoldenベースラインである。
// bikini（カスタム期間切替）機能の実装前に、後方互換（AC-008）を検証できるようにするため作成した。
// 詳細: docs/features/002-bikini/spec/design.md セクション1・3
void main() {
  // UseCaseは `BudgetViewerPage(useCase: mockUseCase, now: ...)` で直接注入する
  // （design.mdの構造的制約2: get_it直呼びをコンストラクタ注入に変更したため、
  // `RetrieveBudgetStateUseCase` のsl登録は不要になった）。
  //
  // `selectExpenseRecordRepository`/`selectExpenseCategoryRepository` は内部で
  // `sl<...>()` を呼び出すため（値自体はモックUseCaseが使わないダミー解決用）、
  // GetItの解決エラーを避けるためにこれらをフェイクとして登録する。
  final mockUseCase = MockRetrieveBudgetStateUseCase();
  final mockExpenseRecordRepository = MockPersonalExpenseRecordRepository();
  final mockExpenseCategoryRepository = MockPersonalExpenseCategoryRepository();
  // AC-012: 共有ノート選択時に `selectExpenseRecordRepository`/
  // `selectExpenseCategoryRepository` が解決する共有版リポジトリ。
  // 値自体はモックUseCaseが使わないダミー解決用（既存のPersonal版と同様）。
  final mockSharedExpenseRecordRepository = MockSharedExpenseRecordRepository();
  final mockSharedExpenseCategoryRepository =
      MockSharedExpenseCategoryRepository();

  void registerFakes() {
    sl.registerFactory<PersonalExpenseRecordRepository>(
      () => mockExpenseRecordRepository,
    );
    sl.registerFactory<PersonalExpenseCategoryRepository>(
      () => mockExpenseCategoryRepository,
    );
    sl.registerFactory<SharedExpenseRecordRepository>(
      () => mockSharedExpenseRecordRepository,
    );
    sl.registerFactory<SharedExpenseCategoryRepository>(
      () => mockSharedExpenseCategoryRepository,
    );
  }

  void unregisterFakes() {
    if (sl.isRegistered<PersonalExpenseRecordRepository>()) {
      sl.unregister<PersonalExpenseRecordRepository>();
    }
    if (sl.isRegistered<PersonalExpenseCategoryRepository>()) {
      sl.unregister<PersonalExpenseCategoryRepository>();
    }
    if (sl.isRegistered<SharedExpenseRecordRepository>()) {
      sl.unregister<SharedExpenseRecordRepository>();
    }
    if (sl.isRegistered<SharedExpenseCategoryRepository>()) {
      sl.unregister<SharedExpenseCategoryRepository>();
    }
  }

  setUp(() {
    unregisterFakes();
    registerFakes();
  });

  tearDown(() {
    reset(mockUseCase);
    reset(mockExpenseRecordRepository);
    reset(mockExpenseCategoryRepository);
    reset(mockSharedExpenseRecordRepository);
    reset(mockSharedExpenseCategoryRepository);
    unregisterFakes();
  });

  /// [now] を注入した [BudgetViewerPage] を返す。
  ///
  /// [selectedNote] を指定すると、`SelectedNoteState` の初期値を
  /// 共有ノート等に切り替えられる（AC-012の検証用）。
  Widget targetBuilder({
    DateTime Function() now = _defaultNow,
    SelectedNote selectedNote = SelectedNote.personal,
  }) => MultiProvider(
    providers: [
      ChangeNotifierProvider<SelectedNoteState>(
        create: (_) => SelectedNoteState()..select(selectedNote),
      ),
      Provider<UserInfo>(
        create: (_) => const UserInfo(uid: 'testUserId', pairId: 'testPairId'),
      ),
    ],
    child: BudgetViewerPage(useCase: mockUseCase, now: now),
  );

  testGoldens(
    '複数カテゴリ（支出0円のカテゴリを含む）を取得できるとき、カテゴリ名と支出額 / 予算額の一覧が表示されること',
    goldenFileName: 'budget_viewer_page_multiple_categories',
    mockFn: () {
      when(mockUseCase.call(any)).thenAnswer(
        (_) async => Right(
          RetrieveBudgetStateOutput(
            begin: DateTime(2026, 7),
            end: DateTime(2026, 8),
            states: [
              BudgetState(name: '食費', totalAmount: 30000, spentAmount: 12000),
              BudgetState(name: '交通費', totalAmount: 5000, spentAmount: 5000),
              BudgetState(name: '趣味', totalAmount: 10000, spentAmount: 0),
            ],
          ),
        ),
      );
    },
    builder: targetBuilder,
    expectFn: (tester) async {
      await tester.pumpAndSettle();

      expect(find.text('食費'), findsOneWidget);
      expect(find.text('12000 / 30000円'), findsOneWidget);
      expect(find.text('交通費'), findsOneWidget);
      expect(find.text('5000 / 5000円'), findsOneWidget);
      expect(find.text('趣味'), findsOneWidget);
      expect(find.text('0 / 10000円'), findsOneWidget);
    },
  );

  testWidgets('カテゴリが0件のとき、エラーにならず空の一覧が表示されること', (tester) async {
    when(mockUseCase.call(any)).thenAnswer(
      (_) async => Right(
        RetrieveBudgetStateOutput(
          begin: DateTime(2026, 7),
          end: DateTime(2026, 8),
          states: const [],
        ),
      ),
    );

    await tester.pumpWidget(GoldenPageWrapper(child: targetBuilder()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('エラーが発生しました'), findsNothing);
  });

  testWidgets('データ取得が失敗（Left）のとき、エラー表示になること', (tester) async {
    when(
      mockUseCase.call(any),
    ).thenAnswer((_) async => Left(Exception('取得に失敗しました')));

    await tester.pumpWidget(GoldenPageWrapper(child: targetBuilder()));
    await tester.pumpAndSettle();

    expect(find.textContaining('取得に失敗しました'), findsOneWidget);
  });

  /// [mockUseCase] が常に正常系（カテゴリ1件）の結果を返すよう設定する。
  ///
  /// なぜ必要か: 月度モードのテストは表示ラベルやUseCaseの呼び出し引数の
  /// 検証が主目的であり、集計結果自体の内容は問わないため、
  /// 呼び出しごとに同じ正常系レスポンスを返す軽量なスタブで十分である。
  void stubUseCaseWithSingleCategory() {
    when(mockUseCase.call(any)).thenAnswer((invocation) async {
      final input =
          invocation.positionalArguments.first as RetrieveBudgetStateInput;
      return Right(
        RetrieveBudgetStateOutput(
          begin: input.begin,
          end: input.end,
          states: [
            BudgetState(name: '食費', totalAmount: 30000, spentAmount: 12000),
          ],
        ),
      );
    });
  }

  Future<void> switchToCustomCycle(WidgetTester tester) async {
    await tester.tap(find.text('月度'));
    await tester.pumpAndSettle();
  }

  /// 月度モードの `_PeriodNavigationWidget` を表示するテスト向けの pumpWidget ヘルパー。
  ///
  /// なぜ `Scaffold` で包むか: 実際のアプリでは `BudgetViewerPage` は
  /// `MainPage` の `Scaffold.body` に配置される（`lib/presentation/main_page/page.dart`）。
  /// `GoldenPageWrapper` 単体（`Scaffold` なし）で `MaterialApp.home` に直接置くと、
  /// レイアウト制約が実運用と異なり `_PeriodNavigationWidget` の `Row` が
  /// 意図せずオーバーフローする（テスト環境固有の問題）ため、実際の配置に合わせる。
  Future<void> pumpTarget(
    WidgetTester tester, {
    DateTime Function() now = _defaultNow,
    SelectedNote selectedNote = SelectedNote.personal,
  }) async {
    await tester.pumpWidget(
      GoldenPageWrapper(
        child: Scaffold(
          body: targetBuilder(now: now, selectedNote: selectedNote),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('AC-006: 今日が2026/7/5（月前半）のとき、月度に切り替えると2026年7月度のラベルが表示されること', (
    tester,
  ) async {
    stubUseCaseWithSingleCategory();

    await pumpTarget(tester, now: () => DateTime(2026, 7, 5));

    await switchToCustomCycle(tester);

    expect(find.text('2026年7月度（6/16〜7/15）'), findsOneWidget);
  });

  testWidgets('AC-007: 今日が2026/7/20（月後半）のとき、月度に切り替えると2026年8月度のラベルが表示されること', (
    tester,
  ) async {
    stubUseCaseWithSingleCategory();

    await pumpTarget(tester, now: () => DateTime(2026, 7, 20));

    await switchToCustomCycle(tester);

    expect(find.text('2026年8月度（7/16〜8/15）'), findsOneWidget);
  });

  testWidgets(
    'AC-001/002: 今日が2026/7/10のとき、月度に切り替えるとbegin=6/16・end=7/16でUseCaseが呼び出されること',
    (tester) async {
      stubUseCaseWithSingleCategory();

      await pumpTarget(tester, now: () => DateTime(2026, 7, 10));

      await switchToCustomCycle(tester);

      final captured = verify(mockUseCase.call(captureAny)).captured;
      final input = captured.last as RetrieveBudgetStateInput;
      expect(input.begin, DateTime(2026, 6, 16));
      expect(input.end, DateTime(2026, 7, 16));
    },
  );

  testWidgets('AC-009: 月度モードで左矢印をタップすると、1つ前の月度のラベルになりUseCaseが再呼び出しされること', (
    tester,
  ) async {
    stubUseCaseWithSingleCategory();

    await pumpTarget(tester, now: () => DateTime(2026, 7, 10));
    await switchToCustomCycle(tester);

    expect(find.text('2026年7月度（6/16〜7/15）'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();

    expect(find.text('2026年6月度（5/16〜6/15）'), findsOneWidget);

    final captured = verify(mockUseCase.call(captureAny)).captured;
    final input = captured.last as RetrieveBudgetStateInput;
    expect(input.begin, DateTime(2026, 5, 16));
    expect(input.end, DateTime(2026, 6, 16));
  });

  testWidgets('AC-010: 今日が属する月度を表示中のとき右矢印が無効であり、前へ移動後は有効になり元の月度へ戻れること', (
    tester,
  ) async {
    stubUseCaseWithSingleCategory();

    await pumpTarget(tester, now: () => DateTime(2026, 7, 10));
    await switchToCustomCycle(tester);

    // 今日が属する月度（7月度）表示中は右矢印が無効であること。
    final nextButtonWhenCurrent = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.arrow_right),
        matching: find.byType(IconButton),
      ),
    );
    expect(nextButtonWhenCurrent.onPressed, isNull);

    // タップしても無効なため表示は変化しないこと。
    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pumpAndSettle();
    expect(find.text('2026年7月度（6/16〜7/15）'), findsOneWidget);

    // 前の月度へ移動すると右矢印が有効になること。
    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();
    expect(find.text('2026年6月度（5/16〜6/15）'), findsOneWidget);

    final nextButtonWhenPrevious = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.arrow_right),
        matching: find.byType(IconButton),
      ),
    );
    expect(nextButtonWhenPrevious.onPressed, isNotNull);

    // タップで元の月度（7月度）に戻れること。
    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pumpAndSettle();
    expect(find.text('2026年7月度（6/16〜7/15）'), findsOneWidget);
  });

  testWidgets('AC-003/005: 月度モードで支出0円のカテゴリを含む結果が返るとき、0円カテゴリも一覧表示されること', (
    tester,
  ) async {
    when(mockUseCase.call(any)).thenAnswer(
      (_) async => Right(
        RetrieveBudgetStateOutput(
          begin: DateTime(2026, 6, 16),
          end: DateTime(2026, 7, 16),
          states: [
            BudgetState(name: '食費', totalAmount: 30000, spentAmount: 12000),
            BudgetState(name: '趣味', totalAmount: 10000, spentAmount: 0),
          ],
        ),
      ),
    );

    await pumpTarget(tester, now: () => DateTime(2026, 7, 10));
    await switchToCustomCycle(tester);

    expect(find.text('食費'), findsOneWidget);
    expect(find.text('12000 / 30000円'), findsOneWidget);
    expect(find.text('趣味'), findsOneWidget);
    expect(find.text('0 / 10000円'), findsOneWidget);
  });

  testWidgets(
    'AC-012: SelectedNoteStateが共有ノートのとき、月度モードでもUseCaseのuidに共有ノートのIDが渡されること',
    (tester) async {
      stubUseCaseWithSingleCategory();

      await pumpTarget(
        tester,
        now: () => DateTime(2026, 7, 10),
        selectedNote: SelectedNote.shared,
      );
      await switchToCustomCycle(tester);

      final captured = verify(mockUseCase.call(captureAny)).captured;
      final input = captured.last as RetrieveBudgetStateInput;
      expect(input.uid, 'testPairId');
      expect(input.begin, DateTime(2026, 6, 16));
      expect(input.end, DateTime(2026, 7, 16));
    },
  );

  testWidgets('月度モードから暦月に切り替えると、今日基準の当月（暦月）でUseCaseが呼び出されること', (tester) async {
    stubUseCaseWithSingleCategory();

    await pumpTarget(tester, now: () => DateTime(2026, 7, 10));
    await switchToCustomCycle(tester);

    await tester.tap(find.text('暦月'));
    await tester.pumpAndSettle();

    final captured = verify(mockUseCase.call(captureAny)).captured;
    final input = captured.last as RetrieveBudgetStateInput;
    expect(input.begin, DateTime(2026, 7));
    expect(input.end, DateTime(2026, 8));
  });
}
