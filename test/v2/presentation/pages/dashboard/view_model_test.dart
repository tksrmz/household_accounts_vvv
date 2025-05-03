import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/v2/domain/models/dashboard_info.dart';
import 'package:household_accounts/v2/domain/models/vo/expense.dart';
import 'package:household_accounts/v2/domain/models/vo/income.dart';
import 'package:household_accounts/v2/domain/usecases/dashboard.dart';
import 'package:household_accounts/v2/presentation/pages/dashboard/view_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DashboardUseCase>()])
import 'view_model_test.mocks.dart';

void main() {
  final mockUseCase = MockDashboardUseCase();
  final date = DateTime(2025, 1);

  tearDown(() {
    // モックのクリーンアップ
    reset(mockUseCase);
  });

  test('初期化前はModelが初期値であり、エラー状態ではない', () {
    final sut = DashboardViewModel(
      dashboardUseCase: mockUseCase,
    );

    verifyNoMoreInteractions(mockUseCase);
    expect(sut.value.isUninitialized, isTrue);
    expect(sut.value.income, IncomeVo.empty);
    expect(sut.value.expense, ExpenseVo.empty);
    expect(sut.value.isFailed, isFalse);
  });

  group('初期化に成功したとき', () {
    setUp(() {
      // mock
      when(mockUseCase.fetch(date)).thenAnswer(
        (_) async => DashboardInfoModel(IncomeVo(100), ExpenseVo(70)),
      );
    });

    test('Modelを取得でき、エラー状態ではない', () async {
      final sut = DashboardViewModel(
        dashboardUseCase: mockUseCase,
      );
      await sut.init(date);

      verify(mockUseCase.fetch(date)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.income, IncomeVo(100));
      expect(sut.value.expense, ExpenseVo(70));
      expect(sut.value.isFailed, isFalse);
    });

    test('notifyListeners()を呼び出しており、エラー状態ではない', () async {
      final sut = DashboardViewModel(
        dashboardUseCase: mockUseCase,
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
      final sut = DashboardViewModel(
        dashboardUseCase: mockUseCase,
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
      when(mockUseCase.fetch(any)).thenAnswer(
        (_) async => throw DashboardUseCaseException('テスト：エラーが発生しました'),
      );
    });

    test('エラー状態になり、Modelは初期値である', () async {
      final sut = DashboardViewModel(
        dashboardUseCase: mockUseCase,
      );
      await sut.init(date);

      verify(mockUseCase.fetch(date)).called(1);
      expect(sut.value.isUninitialized, isFalse);
      expect(sut.value.income, IncomeVo.empty);
      expect(sut.value.expense, ExpenseVo.empty);
      expect(sut.value.isFailed, isTrue);
    });

    test('notifyListeners()を呼び出している', () async {
      final sut = DashboardViewModel(
        dashboardUseCase: mockUseCase,
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
      final sut = DashboardViewModel(
        dashboardUseCase: mockUseCase,
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
