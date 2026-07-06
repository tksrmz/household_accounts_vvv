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
])
import 'budget_viewer_page_test.mocks.dart';

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

  void registerFakes() {
    sl.registerFactory<PersonalExpenseRecordRepository>(
      () => mockExpenseRecordRepository,
    );
    sl.registerFactory<PersonalExpenseCategoryRepository>(
      () => mockExpenseCategoryRepository,
    );
  }

  void unregisterFakes() {
    if (sl.isRegistered<PersonalExpenseRecordRepository>()) {
      sl.unregister<PersonalExpenseRecordRepository>();
    }
    if (sl.isRegistered<PersonalExpenseCategoryRepository>()) {
      sl.unregister<PersonalExpenseCategoryRepository>();
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
    unregisterFakes();
  });

  Widget targetBuilder() => MultiProvider(
        providers: [
          ChangeNotifierProvider<SelectedNoteState>(
            create: (_) => SelectedNoteState(),
          ),
          Provider<UserInfo>(
            create: (_) => const UserInfo(uid: 'testUserId'),
          ),
        ],
        child: BudgetViewerPage(
          useCase: mockUseCase,
          now: () => DateTime(2026, 7, 1),
        ),
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

  testWidgets(
    'カテゴリが0件のとき、エラーにならず空の一覧が表示されること',
    (tester) async {
      when(mockUseCase.call(any)).thenAnswer(
        (_) async => Right(
          RetrieveBudgetStateOutput(
            begin: DateTime(2026, 7),
            end: DateTime(2026, 8),
            states: const [],
          ),
        ),
      );

      await tester.pumpWidget(
        GoldenPageWrapper(child: targetBuilder()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('エラーが発生しました'), findsNothing);
    },
  );

  testWidgets(
    'データ取得が失敗（Left）のとき、エラー表示になること',
    (tester) async {
      when(mockUseCase.call(any)).thenAnswer(
        (_) async => Left(Exception('取得に失敗しました')),
      );

      await tester.pumpWidget(
        GoldenPageWrapper(child: targetBuilder()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('取得に失敗しました'), findsOneWidget);
    },
  );
}
