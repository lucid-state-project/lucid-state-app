/// Route path and name constants for the app.
class AppRoutes {
  AppRoutes._();

  // Route paths
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String configuration = '/configuration';

  // Route names (used with GoRouter.of(context).goNamed(...))
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String dashboardName = 'dashboard';
  static const String analyticsName = 'analytics';
  static const String configurationName = 'configuration';
}
