import 'package:flutter/material.dart';
import 'core/services/app_initialization_service.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize all core services
    await AppInitializationService().initialize(
      useEmulator: false, // Set to true for development with emulator
    );
  } catch (e) {
    debugPrint('Failed to initialize app: $e');
    // App will still run but with limited functionality
  }

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
