import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/router/app_router.dart';
import 'package:lucid_state_app/app/theme/app_theme.dart';
import 'package:lucid_state_app/core/constants/app_strings.dart';

class LucidStateApp extends StatelessWidget {
  const LucidStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

