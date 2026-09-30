import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const TechMateApp());
}

class TechMateApp extends StatelessWidget {
  const TechMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechMate',
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}