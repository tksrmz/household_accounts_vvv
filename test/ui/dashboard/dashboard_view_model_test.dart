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
import 'package:household_accounts/ui/dashboard/dashboard_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_auth_repository.dart';
import '../../test-util/fake_profile_repository.dart';
import '../../test-util/fake_record_repository.dart';

// なぜtestWidgetsではなくtestを使うか:
// DashboardViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを
// 必要としない。また、testWidgets内で`await streamController.close()`や
// `await subscription.cancel()`をawaitするとハングする既知の問題があるため、
// それを踏まないためにもplain testを使い、ストリームイベントの反映は
// `pumpEventQueue()`で待つ。
//
// なぜCommandの実行状態を網羅的に確かめないか:
// running/completed/errorの振る舞いはCommand自体の責務であり
// test/utils/command_test.dartで固定済みなので、ここでは画面の挙動を
// 説明するのに必要な範囲だけを確かめる。
void main() {
  final period = Period.calendarMonth(2026, 8);
  final userName = UserName('テストユーザー');

  group('読み込み', () {
    test(
      'レコードが未発行でユーザー名の取得も未完了のとき、summaryとuserNameがnullで指定した期間の購読が1回始まること',
      () {
        final target = _buildViewModel(
          period: period,
          fetchUserNameCompleter: Completer<Result<UserName>>(),
        );

        expect(target.viewModel.summary, isNull);
        expect(target.viewModel.userName, isNull);
        expect(target.recordRepository.watchPeriodCallCount, 1);
        expect(target.recordRepository.lastWatchedPeriod, period);
      },
    );

    test('レコードの発行とユーザー名の取得がどちらも完了したとき、summaryとuserNameが揃うこと', () async {
      final target = _buildViewModel(fetchUserNameResult: Result.ok(userName));

      target.recordRepository.recordsController.add([
        _income(1000),
        _expense(300),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.userName, userName);
      expect(target.viewModel.summary?.income, 1000);
      expect(target.viewModel.summary?.expense, 300);
      expect(target.viewModel.summary?.balance, 700);
    });

    test('レコードだけが発行されユーザー名の取得が未完了のとき、userNameがnullのままであること', () async {
      final target = _buildViewModel(
        fetchUserNameCompleter: Completer<Result<UserName>>(),
      );

      target.recordRepository.recordsController.add([_income(100)]);
      await pumpEventQueue();

      expect(target.viewModel.summary, isNotNull);
      expect(target.viewModel.userName, isNull);
    });

    test('ユーザー名だけ取得できレコードが未発行のとき、summaryがnullのままであること', () async {
      final target = _buildViewModel(fetchUserNameResult: Result.ok(userName));

      await pumpEventQueue();

      expect(target.viewModel.userName, userName);
      expect(target.viewModel.summary, isNull);
    });

    test('ユーザー名の取得が失敗したとき、loadがエラーになること', () async {
      final target = _buildViewModel(
        fetchUserNameResult: Result.error(Exception('fetchUserNameエラー')),
      );

      await pumpEventQueue();

      expect(target.viewModel.load.error, isTrue);
      expect(target.viewModel.userName, isNull);
    });
  });

  group('レコードの集計', () {
    test('空のレコードが発行されたとき、収入・支出・残高がすべて0であること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.add([]);
      await pumpEventQueue();

      expect(target.viewModel.summary?.income, 0);
      expect(target.viewModel.summary?.expense, 0);
      expect(target.viewModel.summary?.balance, 0);
    });

    test('複数の収入・支出と振替が発行されたとき、収入と支出だけが合計されること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.add([
        _income(1000),
        _income(200),
        _expense(300),
        _expense(50),
        _transfer(9999),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.summary?.income, 1200);
      expect(target.viewModel.summary?.expense, 350);
      expect(target.viewModel.summary?.balance, 850);
    });

    test('2回目のレコードが発行されたとき、summaryが新しい内容へ更新されること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.add([_income(100)]);
      await pumpEventQueue();
      expect(target.viewModel.summary?.income, 100);

      target.recordRepository.recordsController.add([
        _income(100),
        _income(400),
      ]);
      await pumpEventQueue();

      expect(target.viewModel.summary?.income, 500);
    });
  });

  group('購読のエラー', () {
    test('レコードの購読がExceptionを流したとき、recordsErrorにその例外が保持されること', () async {
      final target = _buildViewModel();
      final exception = Exception('watchPeriodエラー');

      target.recordRepository.recordsController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.recordsError, exception);
    });

    test('エラーのあとに正常なレコードが発行されたとき、recordsErrorが解消されること', () async {
      final target = _buildViewModel();

      target.recordRepository.recordsController.addError(
        Exception('watchPeriodエラー'),
      );
      await pumpEventQueue();
      expect(target.viewModel.recordsError, isNotNull);

      target.recordRepository.recordsController.add([_income(100)]);
      await pumpEventQueue();

      expect(target.viewModel.recordsError, isNull);
      expect(target.viewModel.summary?.income, 100);
    });

    test('レコードの購読がError(実装バグ)を流したとき、状態化されず再送出されること', () async {
      // 再送出はStreamSubscriptionのonErrorコールバック内で起きるため、
      // 購読を開始したZoneの未処理エラーとして観測する(そのままだとテスト全体の
      // 失敗になり、どのtest()の失敗として報告されるかも不安定になる)。
      Object? uncaughtError;
      late _Fixture target;
      runZonedGuarded(
        () => target = _buildViewModel(),
        (error, stackTrace) => uncaughtError = error,
      );

      target.recordRepository.recordsController.addError(ArgumentError('実装バグ'));
      await pumpEventQueue();

      expect(uncaughtError, isA<ArgumentError>());
      expect(target.viewModel.recordsError, isNull);
    });
  });

  group('ノート種別', () {
    test('個人ノートのとき、isPersonalがtrueであること', () {
      final target = _buildViewModel();

      expect(target.viewModel.isPersonal, isTrue);
    });

    test('共有ノートのとき、isPersonalがfalseであること', () {
      final target = _buildViewModel(
        notebook: Notebook.shared(PairId('pair-id')),
      );

      expect(target.viewModel.isPersonal, isFalse);
    });
  });

  group('破棄', () {
    test('disposeしたとき、レコードの購読が解除されること', () async {
      final target = _buildViewModel();

      target.viewModel.dispose();
      await pumpEventQueue();

      expect(target.recordRepository.recordsController.hasListener, isFalse);
    });
  });
}

class _Fixture {
  _Fixture({
    required this.viewModel,
    required this.recordRepository,
    required this.profileRepository,
  });

  final DashboardViewModel viewModel;
  final FakeRecordRepository recordRepository;
  final FakeProfileRepository profileRepository;
}

_Fixture _buildViewModel({
  Notebook? notebook,
  Result<UserName>? fetchUserNameResult,
  Completer<Result<UserName>>? fetchUserNameCompleter,
  Period? period,
}) {
  final userId = UserId('test-uid');
  final recordRepository = FakeRecordRepository();
  final profileRepository = FakeProfileRepository()
    ..fetchUserNameResult =
        fetchUserNameResult ?? Result.ok(UserName('テストユーザー'))
    ..fetchUserNameCompleter = fetchUserNameCompleter;
  final authRepository = FakeAuthRepository(currentUser: UserAuth(uid: userId));

  return _Fixture(
    viewModel: DashboardViewModel(
      recordRepository: recordRepository,
      profileRepository: profileRepository,
      authRepository: authRepository,
      notebook: notebook ?? Notebook.personal(userId),
      period: period ?? Period.calendarMonth(2026, 8),
    ),
    recordRepository: recordRepository,
    profileRepository: profileRepository,
  );
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

Record _transfer(int amount) => Record.transfer(
  id: RecordId('transfer-id'),
  date: _date,
  amount: Amount(amount),
  note: RecordNote(''),
  fromPropertyId: PropertyId('from-property-id'),
  toPropertyId: PropertyId('to-property-id'),
);
