import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/ui/properties/property_editor_view_model.dart';
import 'package:household_accounts/utils/result.dart';

import '../../test-util/fake_property_repository.dart';

final _bank = Property(
  id: PropertyId('bank'),
  name: PropertyName('銀行'),
  balance: -5000,
);

// なぜCommandの実行状態を網羅的に確かめないか:
// running/completed/errorの振る舞いはCommand自体の責務であり
// test/utils/command_test.dartで固定済みなので、ここでは画面の挙動を
// 説明するのに必要な範囲だけを確かめる。
void main() {
  group('初期状態', () {
    test('資産を渡さずに生成したとき、追加として空欄から始まり、エラーは出さず保存できないこと', () {
      final target = _buildFixture();

      expect(target.viewModel.isEditing, isFalse);
      expect(target.viewModel.nameInput, '');
      expect(target.viewModel.balanceInput, '');
      expect(target.viewModel.hasNameError, isFalse);
      expect(target.viewModel.hasBalanceError, isFalse);
      expect(target.viewModel.canSave, isFalse);
    });

    test('資産を渡して生成したとき、編集としてその資産の内容から始まり、保存できること', () {
      final target = _buildFixture(property: _bank);

      expect(target.viewModel.isEditing, isTrue);
      expect(target.viewModel.nameInput, '銀行');
      expect(target.viewModel.balanceInput, '-5000');
      expect(target.viewModel.canSave, isTrue);
    });
  });

  group('資産名のライブ検証', () {
    test('空欄にしたとき、エラーになり保存できないこと', () {
      final target = _buildFixture(property: _bank);

      target.viewModel.onNameChanged('');

      expect(target.viewModel.hasNameError, isTrue);
      expect(target.viewModel.canSave, isFalse);
    });

    test('21文字にしたとき、エラーになり保存できないこと', () {
      final target = _buildFixture(property: _bank);

      target.viewModel.onNameChanged('あ' * (PropertyName.maxLength + 1));

      expect(target.viewModel.hasNameError, isTrue);
      expect(target.viewModel.canSave, isFalse);
    });

    test('エラーのあとに20文字へ直したとき、エラーが解消し保存できること', () {
      final target = _buildFixture(property: _bank);
      target.viewModel.onNameChanged('');

      target.viewModel.onNameChanged('あ' * PropertyName.maxLength);

      expect(target.viewModel.hasNameError, isFalse);
      expect(target.viewModel.canSave, isTrue);
    });
  });

  group('資産額のライブ検証', () {
    // int.tryParseが受け付けてしまう表記(前後の空白・16進・プラス記号)も、
    // 画面の表示と保存される値が食い違うため不正として扱う
    for (final (label, input) in [
      ('空欄', ''),
      ('マイナス記号だけ', '-'),
      ('数字以外を含む', '12a'),
      ('前後に空白を含む', ' 12'),
      ('16進表記', '0x10'),
      ('プラス記号付き', '+5'),
      ('intの範囲を超える桁数', '99999999999999999999'),
    ]) {
      test('$label($input)にしたとき、エラーになり保存できないこと', () {
        final target = _buildFixture(property: _bank);

        target.viewModel.onBalanceChanged(input);

        expect(target.viewModel.hasBalanceError, isTrue);
        expect(target.viewModel.canSave, isFalse);
      });
    }

    for (final (label, input) in [
      ('ゼロ', '0'),
      ('正の整数', '12000'),
      ('負の整数', '-5000'),
    ]) {
      test('$label($input)にしたとき、エラーにならず保存できること', () {
        final target = _buildFixture(property: _bank);

        target.viewModel.onBalanceChanged(input);

        expect(target.viewModel.hasBalanceError, isFalse);
        expect(target.viewModel.canSave, isTrue);
      });
    }
  });

  group('通知', () {
    test('追加で妥当な名前と資産額を入力し終えたとき、保存できるようになったことが通知されること', () {
      // エラー表示は未入力のときも妥当な入力のときも出ないため、エラーの変化だけを
      // 通知の契機にすると、保存ボタンが押せるようにならない(回帰テスト)
      final target = _buildFixture();
      target.viewModel.onNameChanged('財布');
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.onBalanceChanged('0');

      expect(notifyCount, 1);
      expect(target.viewModel.canSave, isTrue);
    });

    test('判定の変わらない入力が続いたとき、通知されないこと', () {
      final target = _buildFixture(property: _bank);
      var notifyCount = 0;
      target.viewModel.addListener(() => notifyCount++);

      target.viewModel.onNameChanged('銀行口座');
      target.viewModel.onBalanceChanged('-50000');

      expect(notifyCount, 0);
    });
  });

  group('追加の保存', () {
    test('妥当な入力で保存したとき、入力した名前と残高でRepositoryへ追加されること', () async {
      final target = _buildFixture();
      target.viewModel.onNameChanged('財布');
      target.viewModel.onBalanceChanged('-300');

      await target.viewModel.submit();

      expect(target.repository.addCalls, [
        (name: PropertyName('財布'), balance: -300),
      ]);
      expect(target.viewModel.save.completed, isTrue);
    });

    test('何も入力せずに保存したとき、Repositoryを呼ばず資産名がエラーになること', () async {
      // 保存ボタンは無効化されているが、型境界に不正な値を渡さない防御を確かめる
      final target = _buildFixture();

      await target.viewModel.submit();

      expect(target.repository.addCalls, isEmpty);
      expect(target.viewModel.hasNameError, isTrue);
    });

    test('追加が失敗したとき、コマンドがエラーになること', () async {
      final target = _buildFixture();
      target.repository.addResult = Result.error(Exception('addエラー'));
      target.viewModel.onNameChanged('財布');
      target.viewModel.onBalanceChanged('0');

      await target.viewModel.submit();

      expect(target.viewModel.save.error, isTrue);
    });
  });

  group('編集の保存', () {
    test('名前だけを変えて保存したとき、名前だけがRepositoryへ渡り残高は書かれないこと', () async {
      final target = _buildFixture(property: _bank);
      target.viewModel.onNameChanged('メインバンク');

      await target.viewModel.submit();

      expect(target.repository.updateCalls, [
        (id: _bank.id, name: PropertyName('メインバンク'), balance: null),
      ]);
    });

    test('残高だけを変えて保存したとき、残高だけがRepositoryへ渡り名前は書かれないこと', () async {
      final target = _buildFixture(property: _bank);
      target.viewModel.onBalanceChanged('8000');

      await target.viewModel.submit();

      expect(target.repository.updateCalls, [
        (id: _bank.id, name: null, balance: 8000),
      ]);
    });

    test('名前と残高の両方を変えて保存したとき、両方がRepositoryへ渡ること', () async {
      final target = _buildFixture(property: _bank);
      target.viewModel.onNameChanged('メインバンク');
      target.viewModel.onBalanceChanged('8000');

      await target.viewModel.submit();

      expect(target.repository.updateCalls, [
        (id: _bank.id, name: PropertyName('メインバンク'), balance: 8000),
      ]);
    });

    test('一度変えた入力を元の内容へ戻して保存したとき、Repositoryを呼ばずに成功すること', () async {
      final target = _buildFixture(property: _bank);
      target.viewModel.onNameChanged('メインバンク');
      target.viewModel.onNameChanged('銀行');

      await target.viewModel.submit();

      expect(target.repository.updateCalls, isEmpty);
      expect(target.repository.addCalls, isEmpty);
      expect(target.viewModel.save.completed, isTrue);
    });

    test('更新が失敗したとき、コマンドがエラーになること', () async {
      final target = _buildFixture(property: _bank);
      target.repository.updateResult = Result.error(Exception('updateエラー'));
      target.viewModel.onBalanceChanged('8000');

      await target.viewModel.submit();

      expect(target.viewModel.save.error, isTrue);
    });
  });
}

class _Fixture {
  _Fixture({required this.viewModel, required this.repository});

  final PropertyEditorViewModel viewModel;
  final FakePropertyRepository repository;
}

_Fixture _buildFixture({Property? property}) {
  final repository = FakePropertyRepository();
  return _Fixture(
    viewModel: PropertyEditorViewModel(
      propertyRepository: repository,
      property: property,
    ),
    repository: repository,
  );
}
