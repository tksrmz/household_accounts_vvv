import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'feature/auth_gate/index.dart';
import 'firebase_options.dart';
import 'util/service_locator/main.dart';
import 'v2/data/repositories/firestore/personal_expense_repository.dart';
import 'v2/data/repositories/firestore/personal_income_repository.dart';
import 'v2/data/repositories/firestore/public_profile_repository.dart';
import 'v2/data/repositories/firestore/shared_expense_repository.dart';
import 'v2/data/repositories/firestore/shared_income_repository.dart';
import 'v2/domain/models/vo/user_id.dart';
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
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.useFirestoreEmulator('localhost', 8080);
    firestoreInstance.settings = const Settings(
      persistenceEnabled: false,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SelectedNoteState(),
        ),
        // FirebaseAuthの状態を監視する
        StreamProvider<User?>.value(
          initialData: FirebaseAuth.instance.currentUser,
          value: FirebaseAuth.instance.authStateChanges(),
        ),
        Provider<FirebaseFirestore>.value(
          value: FirebaseFirestore.instance,
        ),
        Provider<PublicProfileRepository>(
          create: (_) => FirestorePublicProfileRepository(
            FirebaseFirestore.instance,
          ),
        ),
        ProxyProvider2<SelectedNoteState, User?, IncomeRepository>(
          update: (context, selectedNote, user, __) {
            final firestore = context.read<FirebaseFirestore>();
            // FIXME: userがnullの時を適切にハンドリングする
            final userId = UserIdVo(user?.uid ?? '');

            return selectedNote.isPersonal
                ? FirestorePersonalIncomeRepository(firestore, userId)
                : FirestoreSharedIncomeRepository(firestore, userId);
          },
        ),
        ProxyProvider2<SelectedNoteState, User?, ExpenseRepository>(
          update: (context, selectedNote, user, __) {
            final firestore = context.read<FirebaseFirestore>();
            // FIXME: userがnullの時を適切にハンドリングする
            final userId = UserIdVo(user?.uid ?? '');

            return selectedNote.isPersonal
                ? FirestorePersonalExpenseRepository(firestore, userId)
                : FirestoreSharedExpenseRepository(firestore, userId);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Household Accounts',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthGate(),
      ),
    );
  }
}
