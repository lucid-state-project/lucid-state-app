import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/features/analytics/presentation/pages/analytics_page.dart';
import 'package:lucid_state_app/features/auth/presentation/pages/login_page.dart';
import 'package:lucid_state_app/features/auth/presentation/pages/register_page.dart';
import 'package:lucid_state_app/features/configuration/presentation/pages/configuration_page.dart';
import 'package:lucid_state_app/features/dashboard/presentation/pages/dashboard_page.dart';

/// App-wide GoRouter instance.
///
/// Initial location is [AppRoutes.login].
/// All routes are flat (no nesting) and easy to extend.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    // Auth routes
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginName,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.registerName,
      builder: (context, state) => const RegisterPage(),
    ),

    // Main routes
    GoRoute(
      path: AppRoutes.dashboard,
      name: AppRoutes.dashboardName,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const DashboardPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.analytics,
      name: AppRoutes.analyticsName,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const AnalyticsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.configuration,
      name: AppRoutes.configurationName,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const ConfigurationPage(),
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ),
  ],
);
