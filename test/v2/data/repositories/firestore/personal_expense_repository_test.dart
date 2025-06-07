import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/repositories/firestore/personal_expense_repository.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/data/models/expense_record_model.dart';
import 'package:household_accounts/v2/domain/models/expense_category.dart';
import 'package:household_accounts/v2/domain/models/expense_record.dart';
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/record_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/record_date.dart';
import 'package:household_accounts/v2/domain/models/vo/record_id.dart';
import 'package:household_accounts/v2/domain/models/vo/record_note.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<FirestoreService>(),
])
import 'personal_expense_repository_test.mocks.dart';

void main() {
  group('fetchMonthly', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    group('1件取得', () {
      test('指定された月の支出一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => Right([
              {'amount': 100}
            ]));

        final target = FirestorePersonalExpenseRepository(
          mockFirestoreService,
          userId,
        );
        final result = await target.fetchMonthly(date);
        final expenseList = result.getOrElse(() => []);

        verify(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(result.isRight(), isTrue);
        expect(expenseList, hasLength(1));
        expect(expenseList[0], ExpenseVo(100));
      });
    });

    group('0件取得', () {
      test('指定された月の支出一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => Right([]));

        final target = FirestorePersonalExpenseRepository(
          mockFirestoreService,
          userId,
        );
        final result = await target.fetchMonthly(date);
        final expenseList = result.getOrElse(() => []);

        // クエリの正しさは別のテストで確認しているので、取得した結果だけ確認
        expect(result.isRight(), isTrue);
        expect(expenseList, hasLength(0));
      });
    });

    <({String description, dynamic value})>[
      (
        description: 'amountが数値以外のとき、TypeErrorが発生する',
        value: '100',
      ),
      (
        description: 'amountがnullのとき、TypeErrorが発生する',
        value: null,
      ),
    ].forEach((element) {
      final (:description, :value) = element;
      test(description, () async {
        final date = DateTime(2025, 1);
        when(mockFirestoreService.fetchAllPersonalExpensesOf(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => Right([
              {'amount': value}
            ]));

        final target = FirestorePersonalExpenseRepository(
          mockFirestoreService,
          userId,
        );
        expect(
          () async => await target.fetchMonthly(date),
          throwsA(isA<TypeError>()),
        );
      });
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final date = DateTime(2025, 1);
      final exception = Exception('test error');
      when(mockFirestoreService.fetchAllPersonalExpensesOf(
        userId,
        date.year,
        date.month,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePersonalExpenseRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.fetchMonthly(date);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('add', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('支出レコードを追加できる', () async {
      final record = ExpenseRecordVo(
        id: RecordIdVo('test-record-id'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(1000),
        note: RecordNoteVo('テスト支出'),
        property: PropertyVo.deleted,
        category: ExpenseCategoryVo.deleted,
        hasCheckedOut: false,
      );

      when(mockFirestoreService.addPersonalExpense(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestorePersonalExpenseRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.add(record);

      verify(mockFirestoreService.addPersonalExpense(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final record = ExpenseRecordVo(
        id: RecordIdVo('test-record-id'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(1000),
        note: RecordNoteVo('テスト支出'),
        property: PropertyVo.deleted,
        category: ExpenseCategoryVo.deleted,
        hasCheckedOut: false,
      );

      final exception = Exception('test error');
      when(mockFirestoreService.addPersonalExpense(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePersonalExpenseRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.add(record);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('delete', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('支出レコードを削除できる', () async {
      const recordId = RecordIdVo('test-record-id');

      when(mockFirestoreService.deletePersonalExpense(
        userId,
        recordId.value,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestorePersonalExpenseRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.delete(recordId);

      verify(mockFirestoreService.deletePersonalExpense(
        userId,
        recordId.value,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const recordId = RecordIdVo('test-record-id');
      final exception = Exception('test error');

      when(mockFirestoreService.deletePersonalExpense(
        userId,
        recordId.value,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePersonalExpenseRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.delete(recordId);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });
}
