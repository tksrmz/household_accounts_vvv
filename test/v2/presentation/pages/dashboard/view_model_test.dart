import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/summary.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/usecases/summary.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<SummaryUseCase>()])
import 'view_model_test.mocks.dart';

void main() {
  final mockSummaryUseCase = MockSummaryUseCase();
  final date = DateTime(2025, 1);

  tearDown(() {
    // モックのクリーンアップ
    reset(mockSummaryUseCase);
  });

  test('初期化前はModelが初期値であり、エラー状態ではない', () {
    final sut = SummaryViewModel(
      summaryUseCase: mockSummaryUseCase,
    );

    verifyNoMoreInteractions(mockSummaryUseCase);
    expect(sut.value.isUninitialized, isTrue);
    expect(sut.value.income, Income.empty);
    expect(sut.value.expense, Expense.empty);
    expect(sut.value.isFailed, isFalse);
  });

  group('初期化に成功したとき', () {
    setUp(() {
      // mock
      when(mockSummaryUseCase.fetch(date)).thenAnswer(
        (_) async => SummaryModel(Income(100), Expense(70)),
      );
    });

    test('Modelを取得でき、エラー状態ではない', () async {
      final sut = SummaryViewModel(
        summaryUseCase: mockSummaryUseCase,
      );
      await sut.init(date);

      verify(mockSummaryUseCase.fetch(date)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.income, Income(100));
      expect(sut.value.expense, Expense(70));
      expect(sut.value.isFailed, isFalse);
    });

    test('notifyListeners()を呼び出しており、エラー状態ではない', () async {
      final sut = SummaryViewModel(
        summaryUseCase: mockSummaryUseCase,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.isFailed, isFalse);
    });

    test('init()が2回以上呼び出されても何もしない', () async {
      final sut = SummaryViewModel(
        summaryUseCase: mockSummaryUseCase,
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
      when(mockSummaryUseCase.fetch(any)).thenAnswer(
        (_) async => throw SummaryUseCaseException('テスト：エラーが発生しました'),
      );
    });

    test('エラー状態になり、Modelは初期値である', () async {
      final sut = SummaryViewModel(
        summaryUseCase: mockSummaryUseCase,
      );
      await sut.init(date);

      verify(mockSummaryUseCase.fetch(date)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.income, Income.empty);
      expect(sut.value.expense, Expense.empty);
      expect(sut.value.isFailed, isTrue);
    });

    test('notifyListeners()を呼び出している', () async {
      final sut = SummaryViewModel(
        summaryUseCase: mockSummaryUseCase,
      );
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date);
      expect(notifyListenersCalled, isTrue);

      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.isFailed, isTrue);
    });

    test('init()が2回以上呼び出されても何もしない', () async {
      final sut = SummaryViewModel(
        summaryUseCase: mockSummaryUseCase,
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
