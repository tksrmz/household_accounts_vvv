import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/presentation/dashboard/view_model.dart';

void main() {
  test('インスタンス化されたときModelがnullである', () {
    final viewModel = SummaryViewModel();

    expect(viewModel.income, isNull);
    expect(viewModel.expense, isNull);
    expect(viewModel.budgetGraphDataList, isNull);
    expect(viewModel.isInitialized, isFalse);
  });

  test('初期化後、Modelがすべてnullでないならローディング中ではない', () async {
    final viewModel = SummaryViewModel();
    await viewModel.init();

    expect(viewModel.income, isNotNull);
    expect(viewModel.expense, isNotNull);
    expect(viewModel.budgetGraphDataList, isNotNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isFalse);
  });

  test('初期化後、incomeがnullならエラー', () async {
    final viewModel = SummaryViewModelMock1();
    await viewModel.init();

    expect(viewModel.income, isNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isTrue);
  });

  test('初期化後、expenseがnullならエラー', () async {
    final viewModel = SummaryViewModelMock2();
    await viewModel.init();

    expect(viewModel.expense, isNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isTrue);
  });

  test('初期化後、budgetGraphDataListがnullならエラー', () async {
    final viewModel = SummaryViewModelMock3();
    await viewModel.init();

    expect(viewModel.budgetGraphDataList, isNull);
    expect(viewModel.isInitialized, isTrue);
    expect(viewModel.hasError, isTrue);
  });
}

class SummaryViewModelMock1 extends SummaryViewModel {
  @override
  Future<void> init() async {
    super.init();
    income = null;
  }
}

class SummaryViewModelMock2 extends SummaryViewModel {
  @override
  Future<void> init() async {
    super.init();
    expense = null;
  }
}

class SummaryViewModelMock3 extends SummaryViewModel {
  @override
  Future<void> init() async {
    super.init();
    budgetGraphDataList = null;
  }
}
