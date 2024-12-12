import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:household_accounts/feature/auth_gate/use_case.dart';

import 'feature/auth_gate/index.dart';
import 'firebase_options.dart';
import 'util/service_locator/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to the local emulator if running in debug mode
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

  initializeServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Household Accounts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthGate(AuthUseCase()),
    );
  }
}
