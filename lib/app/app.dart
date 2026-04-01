import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_theme.dart';
import 'package:lucid_state_app/core/constants/app_strings.dart';
import 'package:lucid_state_app/features/home/presentation/pages/home_page.dart';

class LucidStateApp extends StatelessWidget {
  const LucidStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
