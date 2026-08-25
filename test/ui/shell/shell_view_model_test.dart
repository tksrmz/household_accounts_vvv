import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/pair_status.dart';
import 'package:household_accounts/domain/models/user_auth.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/ui/shell/shell_view_model.dart';
import 'package:household_accounts/v2/presentation/pages/state_managements/selected_note_state.dart';

import '../../test-util/fake_auth_repository.dart';
import '../../test-util/fake_profile_repository.dart';

// なぜtestWidgetsではなくtestを使うか:
// ShellViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを必要としない。
// また、testWidgets内で`await streamController.close()`や`await subscription.cancel()`を
// awaitするとハングする既知の問題があるため、それを踏まないためにも
// plain testを使い、ストリームイベントの反映は`pumpEventQueue()`で待つ。
//
// なぜCommandの実行状態を網羅的に確かめないか:
// running/completed/errorの振る舞いはCommand自体の責務であり
// test/utils/command_test.dartで固定済みなので、ここでは画面の挙動を
// 説明するのに必要な範囲だけを確かめる。
void main() {
  final uid = UserId('test-uid');

  group('ペア検知', () {
    test('ペア検知ストリームが未発行のとき、pairStateがローディングでuserInfoがnullであること', () {
      final target = _buildViewModel();

      expect(target.profileRepository.watchPairStatusCallCount, 1);
      expect(
        target.profileRepository.lastWatchPairStatusUid,
        UserId(uid.value),
      );
      expect(target.viewModel.pairState, isA<ShellPairLoading>());
      expect(target.viewModel.userInfo, isNull);
    });

    test(
      'pairIdが流れたとき、userInfoのuidとpairIdが設定されcanSwitchNoteがtrueであること',
      () async {
        final target = _buildViewModel();

        target.profileRepository.pairStatusController.add(
          PairStatus.paired(PairId('pair-id')),
        );
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
      'notPairedが流れたとき、userInfoのpairIdがnullでcanSwitchNoteがfalseであること',
      () async {
        final target = _buildViewModel();

        target.profileRepository.pairStatusController.add(
          const PairStatus.notPaired(),
        );
        await pumpEventQueue();

        expect(target.viewModel.pairState, isA<ShellPairData>());
        expect(target.viewModel.userInfo?.uid, uid.value);
        expect(target.viewModel.userInfo?.pairId, isNull);
        expect(target.viewModel.canSwitchNote, isFalse);
      },
    );

    test('ペア検知ストリームがエラーを流したとき、pairStateがエラーになること', () async {
      final target = _buildViewModel();

      target.profileRepository.pairStatusController.addError(
        Exception('ペア検知エラー'),
      );
      await pumpEventQueue();

      expect(target.viewModel.pairState, isA<ShellPairError>());
    });

    // Errorが流れたときの再送出(Error.throwWithStackTrace)は意図的にテストしない。
    // plain test内でこの経路を通すと、StreamSubscriptionのonErrorコールバック内で
    // 投げ直した例外がテストのZoneでunhandledな非同期エラーとなり、
    // どのtest()の失敗として報告されるかが不安定になる(既知の問題)。
    // Exceptionが状態化される上のテストで、is! Exceptionによる分岐の入口
    // 自体は経路として通っている。

    test('pairIdが後から変化したとき、userInfoが更新されリスナーへ通知されること', () async {
      // 通知回数は「userInfo更新の明示的なnotifyListeners」と「SelectedNoteState
      // 経由の転送notifyListeners」が両方発火しうる実装詳細のため、正確な回数では
      // なく「各イベントで少なくとも1回は増える」ことだけを確認する。
      final target = _buildViewModel();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.profileRepository.pairStatusController.add(
        const PairStatus.notPaired(),
      );
      await pumpEventQueue();
      expect(notifyCount, greaterThan(0));
      expect(target.viewModel.userInfo?.pairId, isNull);

      final notifyCountAfterFirstEvent = notifyCount;
      target.profileRepository.pairStatusController.add(
        PairStatus.paired(PairId('pair-id')),
      );
      await pumpEventQueue();
      expect(notifyCount, greaterThan(notifyCountAfterFirstEvent));
      expect(target.viewModel.userInfo?.pairId, 'pair-id');
    });

    // ペア解消時にpersonalへ強制リセットする責務そのものはSelectedNoteStateへ
    // 移った(selected_note_state_test.dartで検証済み)。ここではShellViewModelが
    // ペア検知結果を確実にSelectedNoteStateへ伝えていることだけを確かめる。
    test('pairIdが流れたとき、SelectedNoteStateのpairIdが更新されること', () async {
      final target = _buildViewModel();

      target.profileRepository.pairStatusController.add(
        PairStatus.paired(PairId('pair-id')),
      );
      await pumpEventQueue();

      expect(target.selectedNoteState.pairId, PairId('pair-id'));
    });

    test('notPairedが流れたとき、SelectedNoteStateのpairIdがnullに更新されること', () async {
      final target = _buildViewModel();
      target.profileRepository.pairStatusController.add(
        PairStatus.paired(PairId('pair-id')),
      );
      await pumpEventQueue();

      target.profileRepository.pairStatusController.add(
        const PairStatus.notPaired(),
      );
      await pumpEventQueue();

      expect(target.selectedNoteState.pairId, isNull);
    });
  });

  group('ノート切替', () {
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
  });

  group('破棄', () {
    test('disposeしたとき、以後のペア検知イベントで通知されないこと', () async {
      final target = _buildViewModel();
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.dispose();
      // 既知の問題(testWidgets内でcloseやcancelをawaitするとハングする)を踏まないため、
      // ここでもcontroller.close()は呼ばない。close済みでなくともadd自体は無害。
      target.profileRepository.pairStatusController.add(
        const PairStatus.notPaired(),
      );
      await pumpEventQueue();

      expect(notifyCount, 0);
    });
  });
}

class _Fixture {
  _Fixture({
    required this.viewModel,
    required this.profileRepository,
    required this.authRepository,
    required this.selectedNoteState,
  });

  final ShellViewModel viewModel;
  final FakeProfileRepository profileRepository;
  final FakeAuthRepository authRepository;
  final SelectedNoteState selectedNoteState;
}

_Fixture _buildViewModel() {
  final profileRepository = FakeProfileRepository();
  final authRepository = FakeAuthRepository(
    currentUser: UserAuth.signedIn(UserId('test-uid')),
  );
  final selectedNoteState = SelectedNoteState();
  final viewModel = ShellViewModel(
    authRepository: authRepository,
    selectedNoteState: selectedNoteState,
    profileRepository: profileRepository,
  );

  return _Fixture(
    viewModel: viewModel,
    profileRepository: profileRepository,
    authRepository: authRepository,
    selectedNoteState: selectedNoteState,
  );
}
