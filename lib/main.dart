import 'package:firebase_core/firebase_core.dart';
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
