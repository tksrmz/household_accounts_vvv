import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/entity/expense.dart';
import 'package:household_accounts/entity/income.dart';
import 'package:household_accounts/presentation/dashboard/model/summary.dart';
import 'package:household_accounts/presentation/dashboard/repository/expense_repository.dart';
import 'package:household_accounts/presentation/dashboard/repository/income_repository.dart';
import 'package:household_accounts/presentation/dashboard/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<SummaryModel>(),
  MockSpec<IncomeRepository>(),
  MockSpec<ExpenseRepository>(),
])
import 'view_model_test.mocks.dart';

void main() {
  final date = DateTime(2025, 1);

  test('インスタンス化されたときModelがnullである', () {
    final viewModel = SummaryViewModel(
      summaryModel: SummaryModel(
        incomeRepository: MockIncomeRepository(),
        expenseRepository: MockExpenseRepository(),
      ),
    );

    expect(viewModel.income, isNull);
    expect(viewModel.expense, isNull);
    expect(viewModel.isAfterInitialization, isFalse);
    expect(viewModel.hasError, isFalse);
  });

  group('Modelを通常通り取得できる場合', () {
    late SummaryModel summaryModel;
    late SummaryViewModel sut;

    setUp(() {
      // mock
      summaryModel = MockSummaryModel();
      when(summaryModel.fetch(date)).thenAnswer(
        (_) async => Summary(Income(100), Expense(70)),
      );

      // initialize ViewModel
      sut = SummaryViewModel(
        summaryModel: summaryModel,
      );
    });

    test('初期化後はModelを取得できる', () async {
      await sut.init(date);

      verify(summaryModel.fetch(date)).called(1);
      expect(sut.income, Income(100));
      expect(sut.expense, Expense(70));
      expect(sut.isAfterInitialization, isTrue);
      expect(sut.hasError, isFalse);
    });

    test('初期化時にnotifyListeners()を呼び出している', () async {
      var notifyListenersCalled = false;
      sut.addListener(() {
        notifyListenersCalled = true;
      });

      expect(notifyListenersCalled, isFalse);
      await sut.init(date);
      expect(notifyListenersCalled, isTrue);
      // notifyListeners()が呼び出されたら初期化が完了している
      expect(sut.isAfterInitialization, isTrue);
    });
  });

  test('サマリーの取得に失敗したらエラー状態になる', () async {
    final mockSummaryModel = MockSummaryModel();
    when(mockSummaryModel.fetch(any))
        .thenThrow(SummaryModelException("テストエラー"));

    final viewModel = SummaryViewModel(
      summaryModel: mockSummaryModel,
    );
    await viewModel.init(date);

    verify(mockSummaryModel.fetch(date)).called(1);
    expect(viewModel.income, isNull);
    expect(viewModel.expense, isNull);
    expect(viewModel.isAfterInitialization, isTrue);
    expect(viewModel.hasError, isTrue);
  });
}
