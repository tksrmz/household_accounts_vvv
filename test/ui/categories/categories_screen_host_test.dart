import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_accounts/data/repositories/category/category_repository.dart';
import 'package:household_accounts/domain/models/category.dart';
import 'package:household_accounts/domain/models/category_id.dart';
import 'package:household_accounts/domain/models/category_name.dart';
import 'package:household_accounts/domain/models/notebook.dart';
import 'package:household_accounts/domain/models/pair_id.dart';
import 'package:household_accounts/domain/models/user_id.dart';
import 'package:household_accounts/ui/categories/categories_screen_host.dart';
import 'package:provider/provider.dart';

import '../../test-util/fake_category_repository.dart';

final _personal = Notebook.personal(UserId('uid'));
final _shared = Notebook.shared(PairId('pair'));

void main() {
  testWidgets('ノートを切り替えたとき、切替前の購読が解除され切替先のノートのカテゴリが表示されること', (tester) async {
    final personalRepository = FakeCategoryRepository();
    final sharedRepository = FakeCategoryRepository();

    await tester.pumpWidget(_app(_personal, personalRepository));
    personalRepository.incomeCategoriesController.add([_income('個人の給与')]);
    await tester.pump();
    expect(find.text('個人の給与'), findsOneWidget);

    // routerはノート切替でRepositoryとHostのキーを同時に差し替える
    await tester.pumpWidget(_app(_shared, sharedRepository));
    sharedRepository.incomeCategoriesController.add([_income('共有の給与')]);
    await tester.pump();

    expect(personalRepository.incomeCategoriesController.hasListener, isFalse);
    expect(personalRepository.expenseCategoriesController.hasListener, isFalse);
    expect(sharedRepository.watchIncomeCategoriesCallCount, 1);
    expect(sharedRepository.watchExpenseCategoriesCallCount, 1);
    expect(find.text('個人の給与'), findsNothing);
    expect(find.text('共有の給与'), findsOneWidget);
  });
}

/// routerの`_notebookScoped`と同じく、選択中ノートを`ValueKey`にしてHostを置く。
Widget _app(Notebook notebook, CategoryRepository repository) {
  return Provider<CategoryRepository>.value(
    value: repository,
    child: MaterialApp(
      home: Scaffold(body: CategoriesScreenHost(key: ValueKey(notebook))),
    ),
  );
}

IncomeCategory _income(String name) =>
    IncomeCategory(id: CategoryId(name), name: CategoryName(name));
