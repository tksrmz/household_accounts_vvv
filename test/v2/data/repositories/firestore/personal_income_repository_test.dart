import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/repositories/firestore/personal_income_repository.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_income_record_service.dart';
import 'package:household_accounts/v2/data/models/income_record_model.dart' as data_model;
import 'package:household_accounts/v2/domain/models/income_category.dart';
import 'package:household_accounts/v2/domain/models/income_record.dart';
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/models/vo/record_amount.dart';
import 'package:household_accounts/v2/domain/models/vo/record_date.dart';
import 'package:household_accounts/v2/domain/models/vo/record_id.dart';
import 'package:household_accounts/v2/domain/models/vo/record_note.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<PersonalIncomeRecordService>(),
])
import 'personal_income_repository_test.mocks.dart';

void main() {
  group('fetchMonthly', () {
    final MockPersonalIncomeRecordService mockService = MockPersonalIncomeRecordService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    group('1件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockService.fetchPersonalIncomes(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => Right([
              data_model.IncomeRecordModel(
                id: 'test-id',
                date: DateTime(2025, 1, 15),
                amount: 100,
                note: 'test note',
                hasCheckedOut: false,
                createdAt: DateTime.now(),
                property: {'ref': '/personalNotes/user1/properties/prop1'},
                category: {'ref': '/personalNotes/user1/incomeCategories/cat1'},
              )
            ]));

        final target = FirestorePersonalIncomeRepository(
          mockService,
          userId,
        );
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        verify(mockService.fetchPersonalIncomes(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(1));
        expect(incomeList[0], IncomeVo(100));
      });
    });

    group('2件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockService.fetchPersonalIncomes(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => Right([
              data_model.IncomeRecordModel(
                id: 'test-id-1',
                date: DateTime(2025, 1, 15),
                amount: 100,
                note: 'test note 1',
                hasCheckedOut: false,
                createdAt: DateTime.now(),
                property: {'ref': '/personalNotes/user1/properties/prop1'},
                category: {'ref': '/personalNotes/user1/incomeCategories/cat1'},
              ),
              data_model.IncomeRecordModel(
                id: 'test-id-2',
                date: DateTime(2025, 1, 16),
                amount: 200,
                note: 'test note 2',
                hasCheckedOut: false,
                createdAt: DateTime.now(),
                property: {'ref': '/personalNotes/user1/properties/prop1'},
                category: {'ref': '/personalNotes/user1/incomeCategories/cat1'},
              )
            ]));

        final target = FirestorePersonalIncomeRepository(
          mockService,
          userId,
        );
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        verify(mockService.fetchPersonalIncomes(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(2));
        expect(incomeList[0], IncomeVo(100));
        expect(incomeList[1], IncomeVo(200));
      });
    });

    group('0件取得', () {
      test('指定された月の収入一覧を取得できる', () async {
        final date = DateTime(2025, 1);
        when(mockService.fetchPersonalIncomes(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => Right([]));

        final target = FirestorePersonalIncomeRepository(
          mockService,
          userId,
        );
        final result = await target.fetchMonthly(date);
        final incomeList = result.getOrElse(() => []);

        verify(mockService.fetchPersonalIncomes(
          userId,
          date.year,
          date.month,
        )).called(1);

        expect(result.isRight(), isTrue);
        expect(incomeList, hasLength(0));
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
        when(mockService.fetchPersonalIncomes(
          userId,
          date.year,
          date.month,
        )).thenAnswer((_) async => Right([
              data_model.IncomeRecordModel(
                id: 'test-id',
                date: DateTime(2025, 1, 15),
                amount: value,
                note: 'test note',
                hasCheckedOut: false,
                createdAt: DateTime.now(),
                property: {'ref': '/personalNotes/user1/properties/prop1'},
                category: {'ref': '/personalNotes/user1/incomeCategories/cat1'},
              )
            ]));

        final target = FirestorePersonalIncomeRepository(
          mockService,
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
      when(mockService.fetchPersonalIncomes(
        userId,
        date.year,
        date.month,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePersonalIncomeRepository(
        mockService,
        userId,
      );
      final result = await target.fetchMonthly(date);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('add', () {
    final MockPersonalIncomeRecordService mockService = MockPersonalIncomeRecordService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('収入レコードを追加できる', () async {
      final record = IncomeRecordModel(
        id: RecordIdVo('test-record-id'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(1000),
        note: RecordNoteVo('テスト収入'),
        property: PropertyModel.deleted,
        category: IncomeCategoryModel.deleted,
        hasCheckedOut: false,
      );

      when(mockService.addPersonalIncome(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestorePersonalIncomeRepository(
        mockService,
        userId,
      );
      final result = await target.add(record);

      verify(mockService.addPersonalIncome(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final record = IncomeRecordModel(
        id: RecordIdVo('test-record-id'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(1000),
        note: RecordNoteVo('テスト収入'),
        property: PropertyModel.deleted,
        category: IncomeCategoryModel.deleted,
        hasCheckedOut: false,
      );

      final exception = Exception('test error');
      when(mockService.addPersonalIncome(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePersonalIncomeRepository(
        mockService,
        userId,
      );
      final result = await target.add(record);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });

  group('delete', () {
    final MockPersonalIncomeRecordService mockService = MockPersonalIncomeRecordService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockService);
    });

    test('収入レコードを削除できる', () async {
      const recordId = RecordIdVo('test-record-id');

      when(mockService.deletePersonalIncome(
        userId,
        recordId.value,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestorePersonalIncomeRepository(
        mockService,
        userId,
      );
      final result = await target.delete(recordId);

      verify(mockService.deletePersonalIncome(
        userId,
        recordId.value,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const recordId = RecordIdVo('test-record-id');
      final exception = Exception('test error');

      when(mockService.deletePersonalIncome(
        userId,
        recordId.value,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestorePersonalIncomeRepository(
        mockService,
        userId,
      );
      final result = await target.delete(recordId);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });
}