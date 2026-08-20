import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../v2/data/repositories/firestore/personal_expense_repository.dart';
import '../v2/data/repositories/firestore/personal_income_repository.dart';
import '../v2/data/repositories/firestore/public_profile_repository.dart';
import '../v2/data/repositories/firestore/shared_expense_repository.dart';
import '../v2/data/repositories/firestore/shared_income_repository.dart';
import '../v2/data/services/firestore/personal/personal_expense_category_service.dart';
import '../v2/data/services/firestore/personal/personal_expense_record_service.dart';
import '../v2/data/services/firestore/personal/personal_income_category_service.dart';
import '../v2/data/services/firestore/personal/personal_income_record_service.dart';
import '../v2/data/services/firestore/personal/personal_property_service.dart';
import '../v2/data/services/firestore/personal/personal_transfer_record_service.dart';
import '../v2/data/services/firestore/profile/private_profile_service.dart';
import '../v2/data/services/firestore/profile/public_profile_service.dart';
import '../v2/data/services/firestore/shared/shared_record_service.dart';
import '../v2/data/services/firestore/transaction/firestore_transaction_service.dart';
import '../v2/domain/models/user_auth.dart';
import '../v2/domain/repositories/expense_repository.dart';
import '../v2/domain/repositories/income_repository.dart';
import '../v2/domain/repositories/public_profile_repository.dart';
import '../v2/presentation/pages/state_managements/selected_note_state.dart';

/// アプリ全域・長寿命の依存(Repository/Service/共有状態)のProvider登録一覧。
///
/// AuthRepositoryインスタンスを先に生成する方式で1段に平坦化した。
List<SingleChildWidget> appProviders(AuthRepository authRepository) => [
  ChangeNotifierProvider(create: (_) => SelectedNoteState()),
  Provider<AuthRepository>.value(value: authRepository),
  Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
  Provider<PublicProfileService>(
    create: (context) => PublicProfileService(context.read()),
  ),
  Provider<PrivateProfileService>(
    create: (context) => PrivateProfileService(context.read()),
  ),
  Provider<PersonalExpenseRecordService>(
    create: (context) => PersonalExpenseRecordService(context.read()),
  ),
  Provider<PersonalIncomeRecordService>(
    create: (context) => PersonalIncomeRecordService(context.read()),
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
  Provider<SharedRecordService>(
    create: (context) => const SharedRecordService(),
  ),
  Provider<FirestoreTransactionService>(
    create: (context) => FirestoreTransactionService(context.read()),
  ),
  Provider<PublicProfileRepository>(
    create: (context) => FirestorePublicProfileRepository(context.read()),
  ),
  StreamProvider<UserAuth>(
    // lazy: false は必須。旧実装はAuthGateが起動直後からwatchしていたため
    // 常に購読済みだったが、新実装のredirectはAuthRepositoryを直接読むので
    // 誰も読まないままだと、最初にreadされた瞬間に古いinitialData
    // (起動時のnotSignIn)が返り、ダッシュボードのRepositoryが
    // 誤ったuidで生成されてしまう。
    lazy: false,
    initialData: authRepository.getCurrentUser(),
    create: (_) => authRepository.authStateChanges(),
  ),
  ProxyProvider2<SelectedNoteState, UserAuth, IncomeRepository>(
    update: (context, selectedNote, user, _) {
      final userId = user.uid;

      return selectedNote.isPersonal
          ? FirestorePersonalIncomeRepository(
              context.read<PersonalIncomeRecordService>(),
              userId,
            )
          : FirestoreSharedIncomeRepository(
              context.read<SharedRecordService>(),
              context.read<PrivateProfileService>(),
              userId,
            );
    },
  ),
  ProxyProvider2<SelectedNoteState, UserAuth, ExpenseRepository>(
    update: (context, selectedNote, user, _) {
      final userId = user.uid;

      return selectedNote.isPersonal
          ? FirestorePersonalExpenseRepository(
              context.read<PersonalExpenseRecordService>(),
              userId,
            )
          : FirestoreSharedExpenseRepository(
              context.read<SharedRecordService>(),
              context.read<PrivateProfileService>(),
              userId,
            );
    },
  ),
];
