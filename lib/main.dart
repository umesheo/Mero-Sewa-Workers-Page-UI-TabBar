import 'package:flutter/material.dart';

import 'package:merosewa_app/splash.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check for Errors
          if (snapshot.hasError) {
            print("Something Went Wrong");
          }

          return MaterialApp(
            title: 'Mero Sewa',
            theme: ThemeData(
              primarySwatch: Colors.cyan,
            ),
            debugShowCheckedModeBanner: false,
            home: SplashPage(),
          );
        });
  }
}
