import 'package:employee_scheduler/core/theme/theme.dart';
import 'package:employee_scheduler/features/auth/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false ,
      title: 'E.S',
      theme: AppTheme.darkThemeMode,
      home: const OnboardingPage(),
      );
  }
}
