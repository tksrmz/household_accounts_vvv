import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/v2/data/services/firestore/profile/public_profile_service.dart';
import 'package:household_accounts/v2/data/services/firestore/profile/private_profile_service.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_expense_record_service.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_income_record_service.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_income_category_service.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_expense_category_service.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_property_service.dart';
import 'package:household_accounts/v2/data/services/firestore/personal/personal_transfer_record_service.dart';
import 'package:household_accounts/v2/data/services/firestore/shared/shared_record_service.dart';
import 'package:household_accounts/v2/data/services/firestore/transaction/firestore_transaction_service.dart';
import 'package:provider/provider.dart';

import 'feature/auth_gate/index.dart';
import 'firebase_options.dart';
import 'util/service_locator/main.dart';
import 'v2/data/repositories/firebase_auth/firebase_auth_repository.dart';
import 'v2/data/repositories/firestore/personal_expense_repository.dart';
import 'v2/data/repositories/firestore/personal_income_repository.dart';
import 'v2/data/repositories/firestore/public_profile_repository.dart';
import 'v2/data/repositories/firestore/shared_expense_repository.dart';
import 'v2/data/repositories/firestore/shared_income_repository.dart';
import 'v2/domain/models/user_auth.dart';
import 'v2/domain/repositories/auth_repository.dart';
import 'v2/domain/repositories/expense_repository.dart';
import 'v2/domain/repositories/income_repository.dart';
import 'v2/domain/repositories/public_profile_repository.dart';
import 'v2/presentation/pages/state_managements/selected_note_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebaseApp();
  initializeServiceLocator();
  runApp(MyApp());
}

Future<void> initializeFirebaseApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // デバッグモードのときのみFirebaseエミュレータに接続
  if (kDebugMode) {
    // initialize Firebase Auth emulator
    final firebaseAuthInstance = FirebaseAuth.instance;
    firebaseAuthInstance.useAuthEmulator('localhost', 9099);
    // log out to clear any previous user
    await firebaseAuthInstance.signOut();

    // initialize Firestore emulator
    // ポートはhousehold_accounts_firebaseリポジトリのfirebase.json（8081）と
    // 一致させる必要がある（8080はローカルで他サービスと衝突するため8081を使用）
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.useFirestoreEmulator('localhost', 8081);
    firestoreInstance.settings = const Settings(
      persistenceEnabled: false,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // UserAuthに依存しないProvider
    final providersNotDependOnUserAuth = [
      ChangeNotifierProvider(
        create: (_) => SelectedNoteState(),
      ),
      Provider<AuthRepository>(
        create: (_) => FirebaseAuthRepository(),
      ),
      Provider<FirebaseFirestore>.value(
        value: FirebaseFirestore.instance,
      ),
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
        create: (context) => SharedRecordService(context.read()),
      ),
      Provider<FirestoreTransactionService>(
        create: (context) => FirestoreTransactionService(context.read()),
      ),
      Provider<PublicProfileRepository>(
        create: (context) => FirestorePublicProfileRepository(context.read()),
      ),
    ];

    return MultiProvider(
      providers: providersNotDependOnUserAuth,
      // HACK AuthRepositoryを読み込むためにbuilderでUserAuthのProviderを作る
      builder: (context, _) {
        // UserAuth自身と、UserAuthに依存するProvider
        final providersDependOnUserAuth = [
          StreamProvider<UserAuth>.value(
            initialData: context.read<AuthRepository>().getCurrentUser(),
            value: context.read<AuthRepository>().authStateChanges(),
          ),
          ProxyProvider2<SelectedNoteState, UserAuth, IncomeRepository>(
            update: (context, selectedNote, user, __) {
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
            update: (context, selectedNote, user, __) {
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

        return MultiProvider(
          providers: providersDependOnUserAuth,
          child: MaterialApp(
            title: 'Household Accounts',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: AuthGate(),
          ),
        );
      },
    );
  }
}
