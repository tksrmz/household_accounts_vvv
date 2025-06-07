import 'package:dartz/dartz.dart';
import 'package:household_accounts/v2/data/repositories/firestore/transfer_repository.dart';
import 'package:household_accounts/v2/data/services/firestore_service.dart';
import 'package:household_accounts/v2/data/models/transfer_record_model.dart';
import 'package:household_accounts/v2/domain/models/property.dart';
import 'package:household_accounts/v2/domain/models/transfer_record.dart';
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
import 'transfer_repository_test.mocks.dart';

void main() {
  group('fetchMonthly', () {
    final MockFirestoreService mockFirestoreService = MockFirestoreService();
    const UserIdVo userId = UserIdVo('samplePersonalNoteId');

    tearDown(() {
      reset(mockFirestoreService);
    });

    test('指定された月の振替一覧を取得できる', () async {
      final date = DateTime(2025, 1);
      final mockModel = TransferRecordModel(
        id: 'test-id',
        date: DateTime(2025, 1, 15),
        amount: 1000,
        note: 'テスト振替',
        hasCheckedOut: false,
        createdAt: DateTime.now(),
        fromProperty: {'ref': '/personalNotes/user123/properties/prop1'},
        toProperty: {'ref': '/personalNotes/user123/properties/prop2'},
      );

      when(mockFirestoreService.fetchPersonalTransfers(
        userId,
        date.year,
        date.month,
      )).thenAnswer((_) async => Right([mockModel]));

      final target = FirestoreTransferRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.fetchMonthly(date);
      final transferList = result.getOrElse(() => []);

      verify(mockFirestoreService.fetchPersonalTransfers(
        userId,
        date.year,
        date.month,
      )).called(1);

      expect(result.isRight(), isTrue);
      expect(transferList, hasLength(1));
      expect(transferList[0].id.value, equals('test-id'));
      expect(transferList[0].amount.value, equals(1000));
    });

    test('振替が存在しない場合、空のリストを返す', () async {
      final date = DateTime(2025, 1);
      when(mockFirestoreService.fetchPersonalTransfers(
        userId,
        date.year,
        date.month,
      )).thenAnswer((_) async => Right([]));

      final target = FirestoreTransferRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.fetchMonthly(date);
      final transferList = result.getOrElse(() => []);

      expect(result.isRight(), isTrue);
      expect(transferList, hasLength(0));
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final date = DateTime(2025, 1);
      final exception = Exception('test error');
      when(mockFirestoreService.fetchPersonalTransfers(
        userId,
        date.year,
        date.month,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreTransferRepository(
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

    test('振替レコードを追加できる', () async {
      final record = TransferRecordVo(
        id: RecordIdVo('test-record-id'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(1000),
        note: RecordNoteVo('テスト振替'),
        source: PropertyVo.deleted,
        destination: PropertyVo.deleted,
        hasCheckedOut: false,
      );

      when(mockFirestoreService.addPersonalTransfer(
        userId,
        any,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreTransferRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.add(record);

      verify(mockFirestoreService.addPersonalTransfer(
        userId,
        any,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      final record = TransferRecordVo(
        id: RecordIdVo('test-record-id'),
        recordDate: RecordDateVo(DateTime(2025, 1, 15)),
        amount: RecordAmountVo(1000),
        note: RecordNoteVo('テスト振替'),
        source: PropertyVo.deleted,
        destination: PropertyVo.deleted,
        hasCheckedOut: false,
      );

      final exception = Exception('test error');
      when(mockFirestoreService.addPersonalTransfer(
        userId,
        any,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreTransferRepository(
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

    test('振替レコードを削除できる', () async {
      const recordId = RecordIdVo('test-record-id');

      when(mockFirestoreService.deletePersonalTransfer(
        userId,
        recordId.value,
      )).thenAnswer((_) async => Right(unit));

      final target = FirestoreTransferRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.delete(recordId);

      verify(mockFirestoreService.deletePersonalTransfer(
        userId,
        recordId.value,
      )).called(1);

      expect(result.isRight(), isTrue);
    });

    test('FirestoreServiceから例外が返された場合、Leftを返す', () async {
      const recordId = RecordIdVo('test-record-id');
      final exception = Exception('test error');

      when(mockFirestoreService.deletePersonalTransfer(
        userId,
        recordId.value,
      )).thenAnswer((_) async => Left(exception));

      final target = FirestoreTransferRepository(
        mockFirestoreService,
        userId,
      );
      final result = await target.delete(recordId);

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), equals(exception));
    });
  });
}