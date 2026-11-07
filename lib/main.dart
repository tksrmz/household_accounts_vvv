import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'config/dependencies.dart';
import 'data/repositories/auth/firebase_auth_repository.dart';
import 'firebase_options.dart';
import 'routing/router.dart';
import 'ui/core/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebaseApp();
  runApp(const MyApp());
}

Future<void> initializeFirebaseApp() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // デバッグモードのときのみFirebaseエミュレータに接続
  if (kDebugMode) {
    // initialize Firebase Auth emulator
    final firebaseAuthInstance = FirebaseAuth.instance;
    firebaseAuthInstance.useAuthEmulator('localhost', 9099);
    // log out to clear any previous user
    await firebaseAuthInstance.signOut();

    // initialize Firestore emulator
    // ポートは同一リポジトリ内のfirebase/firebase.json（8081）と
    // 一致させる必要がある（8080はローカルで他サービスと衝突するため8081を使用）
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.useFirestoreEmulator('localhost', 8081);
    firestoreInstance.settings = const Settings(persistenceEnabled: false);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // GoRouter/認証リスナーをStateで所有する理由:
  // integrationテストはテストごとにpumpWidget(const MyApp())で新しいツリーを作る。
  // グローバルなrouterだと前テストの位置・リスナーが持ち越されるため、State単位で生成・破棄する。
  late final FirebaseAuthRepository _authRepository;
  late final StreamRefreshListenable _refreshListenable;
  late final GoRouter _router;
  late final List<SingleChildWidget> _providers;

  @override
  void initState() {
    super.initState();
    _authRepository = FirebaseAuthRepository();
    _refreshListenable = StreamRefreshListenable(
      _authRepository.authStateChanges(),
    );
    _router = createRouter(
      authRepository: _authRepository,
      refreshListenable: _refreshListenable,
    );
    _providers = appProviders(_authRepository);
  }

  @override
  void dispose() {
    _router.dispose();
    _refreshListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers,
      child: MaterialApp.router(
        title: 'Household Accounts',
        theme: appTheme,
        routerConfig: _router,
      ),
    );
  }
}
