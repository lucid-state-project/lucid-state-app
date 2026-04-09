/// Konfigurasi environment untuk API endpoints
class AppConfig {
  // TODO: Ubah base URL sesuai environment
  /// Base URL backend
  static const String baseUrl = 'http://localhost:8081';

  /// API endpoint paths
  static const String authGuest = '/auth/guest';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  static const String authRefreshToken = '/auth/refresh-token';

  // Session endpoints
  static const String sessionsStart = '/sessions/start';
  static const String sessionsStop = '/sessions/stop';
  static const String sessionsEvaluate = '/sessions/evaluate';
  static const String sessionsList = '/sessions';

  // Summary endpoints
  static const String summaryDaily = '/summary/daily';

  // Category & Activity endpoints
  static const String categories = '/categories';
  static const String activities = '/activities';

  // Timeout configuration
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  /// Get full URL untuk endpoint
  static String getFullUrl(String endpoint) => '$baseUrl$endpoint';
}
