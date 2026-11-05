import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/ui/properties/properties_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_property_repository.dart';

final _wallet = Property(
  id: PropertyId('wallet'),
  name: PropertyName('財布'),
  balance: 12000,
);
final _bank = Property(
  id: PropertyId('bank'),
  name: PropertyName('銀行'),
  balance: -5000,
);

// なぜtestWidgetsではなくtestを使うか:
// PropertiesViewModelは純粋なDartのChangeNotifierであり、Widgetツリーを
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
  group('初期表示', () {
    test('生成した直後のとき、資産の購読が1回始まり、読み込み中であること', () {
      final target = _buildFixture();

      expect(target.repository.watchAllCallCount, 1);
      expect(target.viewModel.isLoading, isTrue);
    });

    test('資産の一覧が届いたとき、読み込みが完了し届いた順に一覧が公開されること', () async {
      final target = _buildFixture();

      target.repository.propertiesController.add([_bank, _wallet]);
      await pumpEventQueue();

      expect(target.viewModel.isLoading, isFalse);
      expect(target.viewModel.properties, [_bank, _wallet]);
    });

    test('資産が1件も無いとき、読み込みが完了し一覧が空であること', () async {
      final target = _buildFixture();

      target.repository.propertiesController.add([]);
      await pumpEventQueue();

      expect(target.viewModel.isLoading, isFalse);
      expect(target.viewModel.properties, isEmpty);
    });

    test('2回目の一覧が発行されたとき、一覧が新しい内容へ更新されること', () async {
      final target = _buildFixture();

      target.repository.propertiesController.add([_wallet]);
      await pumpEventQueue();
      target.repository.propertiesController.add([_bank, _wallet]);
      await pumpEventQueue();

      expect(target.viewModel.properties, [_bank, _wallet]);
    });
  });

  group('資産の削除', () {
    test('削除を実行したとき、対象の資産IDがRepositoryへ1回だけ渡ること', () async {
      final target = _buildFixture();

      await target.viewModel.delete.execute(_wallet.id);

      expect(target.repository.deleteCalls, [_wallet.id]);
    });

    test('削除が失敗したとき、コマンドがエラーになること', () async {
      final target = _buildFixture();
      target.repository.deleteResult = Result.error(Exception('deleteエラー'));

      await target.viewModel.delete.execute(_wallet.id);

      expect(target.viewModel.delete.error, isTrue);
    });
  });

  group('購読のエラー', () {
    test('購読がExceptionを流したとき、loadErrorにその例外が保持されること', () async {
      final target = _buildFixture();
      final exception = Exception('watchAllエラー');

      target.repository.propertiesController.addError(exception);
      await pumpEventQueue();

      expect(target.viewModel.loadError, exception);
    });

    test('エラーのあとに正常な一覧が発行されたとき、loadErrorが解消されること', () async {
      final target = _buildFixture();

      target.repository.propertiesController.addError(Exception('watchAllエラー'));
      await pumpEventQueue();
      expect(target.viewModel.loadError, isNotNull);

      target.repository.propertiesController.add([_wallet]);
      await pumpEventQueue();

      expect(target.viewModel.loadError, isNull);
      expect(target.viewModel.properties, [_wallet]);
    });

    test('購読がError(実装バグ)を流したとき、状態化されず再送出されること', () async {
      // 再送出はStreamSubscriptionのonErrorコールバック内で起きるため、
      // 購読を開始したZoneの未処理エラーとして観測する(そのままだとテスト全体の
      // 失敗になり、どのtest()の失敗として報告されるかも不安定になる)。
      Object? uncaughtError;
      late _Fixture target;
      runZonedGuarded(
        () => target = _buildFixture(),
        (error, stackTrace) => uncaughtError = error,
      );

      target.repository.propertiesController.addError(ArgumentError('実装バグ'));
      await pumpEventQueue();

      expect(uncaughtError, isA<ArgumentError>());
      expect(target.viewModel.loadError, isNull);
    });
  });

  group('破棄', () {
    test('disposeしたとき、資産の購読が解除されること', () async {
      final target = _buildFixture();

      target.viewModel.dispose();
      await pumpEventQueue();

      expect(target.repository.propertiesController.hasListener, isFalse);
    });
  });
}

class _Fixture {
  _Fixture({required this.viewModel, required this.repository});

  final PropertiesViewModel viewModel;
  final FakePropertyRepository repository;
}

_Fixture _buildFixture() {
  final repository = FakePropertyRepository();
  return _Fixture(
    viewModel: PropertiesViewModel(propertyRepository: repository),
    repository: repository,
  );
}
