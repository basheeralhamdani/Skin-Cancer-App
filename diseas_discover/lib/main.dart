import 'package:diseas_discover/pages/homePage.dart';
import 'package:diseas_discover/theme/app_theme.dart'; // --- 1. IMPORT YOUR NEW THEME ---
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // These lines correctly initialize Firebase before the app runs.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disease Discover',
      debugShowCheckedModeBanner: false,

      // --- 2. APPLY THE CENTRALIZED THEME ---
      // This single line replaces the entire old ThemeData block.
      // It provides all the colors, fonts (Poppins), and widget styles we defined.
      theme: AppTheme.lightTheme,

      // The rest of your app will now inherit this beautiful, consistent look.
      home: const HomePage(),
    );
  }
}
