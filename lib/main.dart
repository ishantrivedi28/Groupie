import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:groupie/helper/helper_function.dart';
import 'package:groupie/pages/home_page.dart';
import 'package:groupie/pages/login_page.dart';
import '../shared/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  } else
    await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;
  @override
  void initState() {
    getUserLoggedInStatus();
    super.initState();
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInState().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });

        print(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _isSignedIn ? HomePage() : LoginPage(),
      theme: ThemeData(
          primaryColor: Constants.primaryColor,
          scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
    );
  }
}
