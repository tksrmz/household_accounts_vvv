import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/profile/firestore_profile_repository.dart';
import '../data/repositories/profile/profile_repository.dart';
import '../data/repositories/record/firestore_record_repository.dart';
import '../data/repositories/record/record_repository.dart';
import '../domain/models/notebook.dart';
import '../domain/models/user_auth.dart';
import '../domain/models/user_id.dart';
import '../v2/data/services/firestore/personal/personal_expense_category_service.dart';
import '../v2/data/services/firestore/personal/personal_income_category_service.dart';
import '../v2/data/services/firestore/personal/personal_property_service.dart';
import '../v2/data/services/firestore/personal/personal_transfer_record_service.dart';
import '../v2/data/services/firestore/transaction/firestore_transaction_service.dart';
import '../v2/presentation/pages/state_managements/selected_note_state.dart';

/// アプリ全域・長寿命の依存(Repository/Service/共有状態)のProvider登録一覧。
///
/// AuthRepositoryインスタンスを先に生成する方式で1段に平坦化した。
List<SingleChildWidget> appProviders(AuthRepository authRepository) => [
  ChangeNotifierProvider(create: (_) => SelectedNoteState()),
  Provider<AuthRepository>.value(value: authRepository),
  Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
  Provider<ProfileRepository>(
    create: (context) => FirestoreProfileRepository(context.read()),
  ),
  Provider<PersonalIncomeCategoryService>(
    create: (context) => PersonalIncomeCategoryService(context.read()),
  ),
  Provider<PersonalExpenseCategoryService>(
    create: (context) => PersonalExpenseCategoryService(context.read()),
  ),
  Provider<PersonalPropertyService>(
    create: (context) => PersonalPropertyService(context.read()),
  ),
  Provider<PersonalTransferRecordService>(
    create: (context) => PersonalTransferRecordService(context.read()),
  ),
  Provider<FirestoreTransactionService>(
    create: (context) => FirestoreTransactionService(context.read()),
  ),
  StreamProvider<UserAuth>(
    // lazy: false は必須。旧実装はAuthGateが起動直後からwatchしていたため
    // 常に購読済みだったが、新実装のredirectはAuthRepositoryを直接読むので
    // 誰も読まないままだと、最初にreadされた瞬間に古いinitialData
    // (起動時の未サインイン状態)が返り、ダッシュボードのRepositoryが
    // 誤ったuidで生成されてしまう。
    lazy: false,
    initialData: authRepository.getCurrentUser(),
    create: (_) => authRepository.authStateChanges(),
  ),
  ProxyProvider2<SelectedNoteState, UserAuth, RecordRepository>(
    update: (context, selectedNote, user, _) => FirestoreRecordRepository(
      context.read<FirebaseFirestore>(),
      switch (user) {
        UserAuthSignedIn(:final uid) => selectedNote.resolve(uid),
        // サインイン前もProviderの評価自体は走るが、routerのredirectにより
        // 画面がこのRepositoryを購読する前にサインイン画面へ遷移する。
        // 使われない間のプレースホルダとして無害な個人ノートを与える
        UserAuthNotSignedIn() => Notebook.personal(UserId('not-signed-in')),
      },
    ),
  ),
];
