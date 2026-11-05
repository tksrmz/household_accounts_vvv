import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/data/repositories/property/property_repository.dart';
import 'package:household_accounts/domain/models/notebook.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/property.dart';
import 'package:household_accounts/domain/models/property_id.dart';
import 'package:household_accounts/domain/models/property_name.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/ui/properties/properties_screen_host.dart';
import 'package:provider/provider.dart';

import '../../test-util/fake_property_repository.dart';

final _personal = Notebook.personal(UserId('uid'));
final _shared = Notebook.shared(PairId('pair'));

void main() {
  testWidgets('ノートを切り替えたとき、切替前の購読が解除され切替先のノートの資産が表示されること', (tester) async {
    final personalRepository = FakePropertyRepository();
    final sharedRepository = FakePropertyRepository();

    await tester.pumpWidget(_app(_personal, personalRepository));
    personalRepository.propertiesController.add([_property('個人の財布')]);
    await tester.pump();
    expect(find.text('個人の財布'), findsOneWidget);

    // routerはノート切替でRepositoryとHostのキーを同時に差し替える
    await tester.pumpWidget(_app(_shared, sharedRepository));
    sharedRepository.propertiesController.add([_property('共有の口座')]);
    await tester.pump();

    expect(personalRepository.propertiesController.hasListener, isFalse);
    expect(sharedRepository.watchAllCallCount, 1);
    expect(find.text('個人の財布'), findsNothing);
    expect(find.text('共有の口座'), findsOneWidget);
  });
}

/// routerの`_notebookScoped`と同じく、選択中ノートを`ValueKey`にしてHostを置く。
Widget _app(Notebook notebook, PropertyRepository repository) {
  return Provider<PropertyRepository>.value(
    value: repository,
    child: MaterialApp(
      home: Scaffold(body: PropertiesScreenHost(key: ValueKey(notebook))),
    ),
  );
}

Property _property(String name) =>
    Property(id: PropertyId(name), name: PropertyName(name), balance: 0);
