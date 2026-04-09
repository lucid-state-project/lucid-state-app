/// Base class untuk semua exception di app
/// 
/// Gunakan class ini sebagai parent untuk membuat custom exception
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

/// Exception untuk API/Network errors
/// 
/// Digunakan saat ada error dari backend atau network issue
class ApiException extends AppException {
  final int? statusCode;
  final dynamic responseData;

  ApiException({
    required String message,
    this.statusCode,
    String? code,
    this.responseData,
  }) : super(message: message, code: code);

  @override
  String toString() => 'ApiException [$statusCode] ($code): $message';
}

/// Exception untuk authentication errors
/// 
/// Digunakan saat token invalid, expired, atau permission denied
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exception untuk validation errors (HTTP 400)
/// 
/// Berisi error per field dari server
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({
    required String message,
    this.errors,
    String? code,
  }) : super(message: message, code: code);

  /// Ambil error message untuk field spesifik
  String? getFieldError(String fieldName) => errors?[fieldName];
}

/// Exception untuk server errors (HTTP 5xx)
class ServerException extends AppException {
  ServerException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Exception untuk network connectivity errors
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}
