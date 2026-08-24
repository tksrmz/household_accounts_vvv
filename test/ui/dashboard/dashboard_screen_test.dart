import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/amount.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/notebook.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/period.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/record.dart';
import 'package:household_accounts/domain/models/record_date.dart';
import 'package:household_accounts/domain/models/record_id.dart';
import 'package:household_accounts/domain/models/record_note.dart';
import 'package:household_accounts/domain/models/user_auth.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/domain/models/user_name.dart';
import 'package:household_accounts/ui/dashboard/dashboard_screen.dart';
import 'package:household_accounts/ui/dashboard/dashboard_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_auth_repository.dart';
import '../../test-util/fake_profile_repository.dart';
import '../../test-util/fake_record_repository.dart';
import '../../test-util/golden_helper.dart';

final _userName = UserName('Hoge');

void main() {
  group('golden', () {
    late _Fixture fixture;

    testGoldens(
      'ユーザー名もレコードも未着のとき、ローディングが表示されること',
      goldenFileName: 'dashboard_loading',
      builder: () => (fixture = _buildFixture(
        fetchUserNameCompleter: Completer<Result<UserName>>(),
      )).screen,
    );

    testGoldens(
      'ユーザー名とレコードが揃ったとき、タイトルと集計が表示されること',
      goldenFileName: 'dashboard_loaded',
      builder: () => (fixture = _buildFixture()).screen,
      expectFn: (tester) async {
        await _emitRecords(tester, fixture, [_income(2), _expense(3)]);
      },
    );

    testGoldens(
      'ユーザー名の読み込みに失敗したとき、エラーメッセージが表示されること',
      goldenFileName: 'dashboard_load_failed',
      builder: () => (fixture = _buildFixture(
        fetchUserNameResult: Result.error(Exception('fetchUserNameエラー')),
      )).screen,
      expectFn: (tester) async {
        await tester.pumpAndSettle();
      },
    );
  });

  group('タイトル', () {
    testWidgets('共有ノートのとき、タイトルにふたりの家計簿と表示されること', (tester) async {
      final fixture = _buildFixture(
        notebook: Notebook.shared(PairId('pair-id')),
      );

      await tester.pumpWidget(GoldenPageWrapper(child: fixture.screen));
      await _emitRecords(tester, fixture, [_income(2)]);

      expect(find.text('${_userName.value}のふたりの家計簿'), findsOneWidget);
    });
  });
}

class _Fixture {
  _Fixture({required this.screen, required this.recordRepository});

  final DashboardScreen screen;
  final FakeRecordRepository recordRepository;
}

_Fixture _buildFixture({
  Notebook? notebook,
  Result<UserName>? fetchUserNameResult,
  Completer<Result<UserName>>? fetchUserNameCompleter,
}) {
  final userId = UserId('test-uid');
  final recordRepository = FakeRecordRepository();
  final profileRepository = FakeProfileRepository()
    ..fetchUserNameResult = fetchUserNameResult ?? Result.ok(_userName)
    ..fetchUserNameCompleter = fetchUserNameCompleter;
  final authRepository = FakeAuthRepository(currentUser: UserAuth(uid: userId));

  return _Fixture(
    screen: DashboardScreen(
      viewModel: DashboardViewModel(
        recordRepository: recordRepository,
        profileRepository: profileRepository,
        authRepository: authRepository,
        notebook: notebook ?? Notebook.personal(userId),
        period: Period.calendarMonth(2026, 8),
      ),
    ),
    recordRepository: recordRepository,
  );
}

Future<void> _emitRecords(
  WidgetTester tester,
  _Fixture fixture,
  List<Record> records,
) async {
  fixture.recordRepository.recordsController.add(records);
  await tester.pumpAndSettle();
}

final _date = RecordDate(DateTime(2026, 8, 24));

Record _income(int amount) => Record.income(
  id: RecordId('income-id'),
  date: _date,
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId('category-id'),
  propertyId: PropertyId('property-id'),
);

Record _expense(int amount) => Record.expense(
  id: RecordId('expense-id'),
  date: _date,
  amount: Amount(amount),
  note: RecordNote(''),
  categoryId: CategoryId('category-id'),
  propertyId: PropertyId('property-id'),
);
