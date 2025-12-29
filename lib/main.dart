import 'package:flutter/material.dart';
import 'package:nyaay_dhrishti/Judge/login2_screen.dart';
import 'package:nyaay_dhrishti/court_master/login1_screen.dart';
import 'package:nyaay_dhrishti/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen());
  }
}
