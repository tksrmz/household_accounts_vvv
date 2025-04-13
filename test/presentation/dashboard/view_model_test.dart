import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/model/summary.dart';
import 'package:household_accounts/presentation/dashboard/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SummaryModel>()])
import 'view_model_test.mocks.dart';

void main() {
  final mockSummaryModel = MockSummaryModel();
  final date = DateTime(2025, 1);

  tearDown(() {
    // モックのクリーンアップ
    reset(mockSummaryModel);
  });

  test('初期化前はModelがnullであり、エラー状態ではない', () {
    final sut = SummaryViewModel(
      summaryModel: mockSummaryModel,
    );

    verifyNoMoreInteractions(mockSummaryModel);
    expect(sut.isBeforeInitialization, isTrue);
    expect(sut.income, isNull);
    expect(sut.expense, isNull);
    expect(sut.hasError, isFalse);
  });

  group('初期化に成功したとき', () {
    setUp(() {
      // mock
      when(mockSummaryModel.fetch(date)).thenAnswer(
        (_) async => Summary(Income(100), Expense(70)),
      );
    });

    test('Modelを取得でき、エラー状態ではない', () async {
      final sut = SummaryViewModel(
        summaryModel: mockSummaryModel,
      );
      await sut.init(date);

      verify(mockSummaryModel.fetch(date)).called(1);
      expect(sut.isBeforeInitialization, isFalse);
      expect(sut.income, Income(100));
      expect(sut.expense, Expense(70));
      expect(sut.hasError, isFalse);
      expect(sut.errorMessage, '');
    });

    test('notifyListeners()を呼び出しており、エラー状態ではない', () async {
      final sut = SummaryViewModel(
        summaryModel: mockSummaryModel,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.isBeforeInitialization, isFalse);
      expect(sut.hasError, isFalse);
    });

    test('init()が2回以上呼び出されても何もしない', () async {
      final sut = SummaryViewModel(
        summaryModel: mockSummaryModel,
      );
      var counter = 0;
      sut.addListener(() {
        counter = counter + 1;
      });

      expect(counter, 0);
      await sut.init(date);
      expect(counter, 1);
      await sut.init(date);
      expect(counter, 1);
    });
  });

  group('初期化に失敗したとき', () {
    setUp(() {
      when(mockSummaryModel.fetch(any)).thenAnswer(
        (_) async => throw SummaryModelException('テスト：エラーが発生しました'),
      );
    });

    test('エラー状態になり、Modelを取得できない', () async {
      final sut = SummaryViewModel(
        summaryModel: mockSummaryModel,
      );
      await sut.init(date);

      verify(mockSummaryModel.fetch(date)).called(1);
      expect(sut.isBeforeInitialization, isFalse);
      expect(sut.income, isNull);
      expect(sut.expense, isNull);
      expect(sut.hasError, isTrue);
      expect(sut.errorMessage, 'エラーが発生しました。時間をおいて再度お試しください。');
    });

    test('notifyListeners()を呼び出している', () async {
      final sut = SummaryViewModel(
        summaryModel: mockSummaryModel,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.isBeforeInitialization, isFalse);
      expect(sut.hasError, isTrue);
    });

    test('init()が2回以上呼び出されても何もしない', () async {
      final sut = SummaryViewModel(
        summaryModel: mockSummaryModel,
      );
      var counter = 0;
      sut.addListener(() {
        counter = counter + 1;
      });

      expect(counter, 0);
      await sut.init(date);
      expect(counter, 1);
      await sut.init(date);
      expect(counter, 1);
    });
  });
}
