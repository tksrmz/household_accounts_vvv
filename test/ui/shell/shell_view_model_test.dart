import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/ui/shell/shell_view_model.dart';
import 'package:household_accounts/utils/result.dart';
import 'package:household_accounts/v2/domain/models/user_auth.dart';
import 'package:household_accounts/v2/domain/models/vo/user_id.dart';
import 'package:household_accounts/v2/presentation/pages/state_managements/selected_note_state.dart';

import '../../test-util/fake_auth_repository.dart';

// なぜtestWidgetsではなくtestを使うか:
// ShellViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを必要としない。
// また、testWidgets内で`await streamController.close()`や`await subscription.cancel()`を
// awaitするとハングする既知の問題があるため、それを踏まないためにも
// plain testを使い、ストリームイベントの反映は`pumpEventQueue()`で待つ。
void main() {
  const uid = UserIdVo('test-uid');

  group('ペア検知', () {
    test('ペア検知ストリームが未発行のとき、pairStateがローディングでuserInfoがnullであること', () {
      final target = _buildViewModel();

      expect(target.viewModel.pairState, isA<ShellPairLoading>());
      expect(target.viewModel.userInfo, isNull);
    });

    test(
      'pairIdが流れたとき、userInfoのuidとpairIdが設定されcanSwitchNoteがtrueであること',
      () async {
        final target = _buildViewModel();

        target.pairIdController.add('pair-id');
        await pumpEventQueue();

        final pairState = target.viewModel.pairState;
        expect(pairState, isA<ShellPairData>());
        expect((pairState as ShellPairData).pairId, 'pair-id');
        expect(target.viewModel.userInfo?.uid, uid.value);
        expect(target.viewModel.userInfo?.pairId, 'pair-id');
        expect(target.viewModel.canSwitchNote, isTrue);
      },
    );

    test(
      'nullのpairIdが流れたとき、userInfoのpairIdがnullでcanSwitchNoteがfalseであること',
      () async {
        final target = _buildViewModel();

        target.pairIdController.add(null);
        await pumpEventQueue();

        expect(target.viewModel.pairState, isA<ShellPairData>());
        expect(target.viewModel.userInfo?.uid, uid.value);
        expect(target.viewModel.userInfo?.pairId, isNull);
        expect(target.viewModel.canSwitchNote, isFalse);
      },
    );

    test('ペア検知ストリームがエラーを流したとき、pairStateがエラーになること', () async {
      final target = _buildViewModel();

      target.pairIdController.addError(Exception('ペア検知エラー'));
      await pumpEventQueue();

      expect(target.viewModel.pairState, isA<ShellPairError>());
    });

    test('pairIdが後から変化したとき、userInfoが更新されリスナーへ通知されること', () async {
      final target = _buildViewModel();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.pairIdController.add(null);
      await pumpEventQueue();
      expect(notifyCount, 1);
      expect(target.viewModel.userInfo?.pairId, isNull);

      target.pairIdController.add('pair-id');
      await pumpEventQueue();
      expect(notifyCount, 2);
      expect(target.viewModel.userInfo?.pairId, 'pair-id');
    });
  });

  group('ノート切替', () {
    test('初期状態のとき、selectedNoteがpersonalであること', () {
      final target = _buildViewModel();

      expect(target.viewModel.selectedNote, SelectedNote.personal);
    });

    test(
      'switchNote(shared)を呼んだとき、SelectedNoteStateがsharedになり自身のリスナーへも通知されること',
      () {
        final target = _buildViewModel();
        var notifyCount = 0;
        target.viewModel.addListener(() => notifyCount++);

        target.viewModel.switchNote(SelectedNote.shared);

        expect(target.selectedNoteState.value, SelectedNote.shared);
        expect(target.viewModel.selectedNote, SelectedNote.shared);
        expect(notifyCount, 1);
      },
    );
  });

  group('ログアウト', () {
    test('logoutを実行したとき、AuthRepositoryのsignOutが1回呼ばれること', () async {
      final target = _buildViewModel();

      await target.viewModel.logout.execute();

      expect(target.authRepository.signOutCallCount, 1);
    });

    test('signOutがResult.errorを返したとき、logoutコマンドがエラー状態になること', () async {
      final target = _buildViewModel();
      target.authRepository.signOutResult = Result.error(
        Exception('signOut失敗'),
      );

      await target.viewModel.logout.execute();

      expect(target.viewModel.logout.error, isTrue);
    });
  });

  group('破棄', () {
    test('disposeしたとき、以後のペア検知イベントで通知されないこと', () async {
      final target = _buildViewModel();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.dispose();
      // 既知の問題(testWidgets内でcloseやcancelをawaitするとハングする)を踏まないため、
      // ここでもcontroller.close()は呼ばない。close済みでなくともadd自体は無害。
      target.pairIdController.add('after-dispose');
      await pumpEventQueue();

      expect(notifyCount, 0);
    });
  });
}

class _Fixture {
  _Fixture({
    required this.viewModel,
    required this.pairIdController,
    required this.authRepository,
    required this.selectedNoteState,
  });

  final ShellViewModel viewModel;
  final StreamController<String?> pairIdController;
  final FakeAuthRepository authRepository;
  final SelectedNoteState selectedNoteState;
}

_Fixture _buildViewModel() {
  final pairIdController = StreamController<String?>();
  final authRepository = FakeAuthRepository(
    currentUser: const UserAuth(uid: UserIdVo('test-uid')),
  );
  final selectedNoteState = SelectedNoteState();
  final viewModel = ShellViewModel(
    authRepository: authRepository,
    selectedNoteState: selectedNoteState,
    watchPairId: (_) => pairIdController.stream,
  );

  return _Fixture(
    viewModel: viewModel,
    pairIdController: pairIdController,
    authRepository: authRepository,
    selectedNoteState: selectedNoteState,
  );
}
