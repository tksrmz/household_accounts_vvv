import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'presentation/auth_gate/auth_gate.dart';
import 'util/service_locator/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeServiceLocator();
  runApp(MyApp());
}

// /// We are using a StatefulWidget such that we only create the [Future] once,
// /// no matter how many times our widget rebuild.
// /// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
// /// would re-initialize FlutterFire and make our application re-enter loading state,
// /// which is undesired.
// class App extends StatefulWidget {
//   // Create the initialization Future outside of `build`:
//   @override
//   _AppState createState() => _AppState();
// }
//
// class _AppState extends State<App> {
//   /// The future is part of the state of our widget. We should not call `initializeApp`
//   /// directly inside [build].
//   final Future<FirebaseApp> _initialization = Firebase.initializeApp();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       // Initialize FlutterFire:
//       future: _initialization,
//       builder: (context, snapshot) {
//         // Check for errors
//         if (snapshot.hasError) {
//           return MaterialApp(
//               title: 'Household Accounts',
//               theme: ThemeData(
//                 primarySwatch: Colors.blue,
//               ),
//               home: Scaffold(
//                 body: Center(
//                   child: Text('Something went wrong'),
//                 ),
//               ));
//         }
//
//         // Once complete, show your application
//         if (snapshot.connectionState == ConnectionState.done) {
//           return MyApp();
//         }
//
//         // Otherwise, show something whilst waiting for initialization to complete
//         return MaterialApp(
//             title: 'Household Accounts',
//             theme: ThemeData(
//               primarySwatch: Colors.blue,
//             ),
//             home: Scaffold(
//               body: Center(
//                 child: Text('Loading'),
//               ),
//             ));
//       },
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Household Accounts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthGate(),
    );
  }
}
