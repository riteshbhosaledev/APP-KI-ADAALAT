import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA1MJ_Aa7ve_yK_diKfrvVHaIhSoT_b6Nc",
      appId: "1:478866771246:android:b8814bfe5fb13405babebf",
      messagingSenderId: "478866771246",
      projectId: "nyaay-dhrishti",
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Nyaay-Drishti',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
