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
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.analytics,
      name: AppRoutes.analyticsName,
      builder: (context, state) => const AnalyticsPage(),
    ),
    GoRoute(
      path: AppRoutes.configuration,
      name: AppRoutes.configurationName,
      builder: (context, state) => const ConfigurationPage(),
    ),
  ],
);
