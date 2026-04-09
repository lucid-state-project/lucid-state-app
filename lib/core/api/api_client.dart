import 'dart:io';
import 'package:dio/dio.dart';
import 'config.dart';
import 'exceptions.dart';

/// HTTP Client untuk komunikasi dengan backend
/// 
/// Menangani:
/// - Request/Response Intercepting
/// - Error handling & mapping
/// - Token management
/// - Logging
/// 
/// Gunakan sebagai singleton: ApiClient().get(...), ApiClient().post(...), dll
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  late final Dio _dio;

  /// Private constructor untuk singleton pattern
  ApiClient._internal() {
    _initializeDio();
  }

  /// Get singleton instance
  factory ApiClient() {
    return _instance;
  }

  /// Initialize Dio dengan konfigurasi default
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Tambahkan interceptor untuk logging dan error handling
    _dio.interceptors.add(_ApiInterceptor());
  }

  /// GET request
  /// 
  /// [path] - endpoint path (contoh: '/auth/guest')
  /// [queryParams] - URL query parameters
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParams,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  /// 
  /// [path] - endpoint path (contoh: '/auth/login')
  /// [data] - request body
  /// [queryParams] - URL query parameters
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  /// 
  /// [path] - endpoint path
  /// [data] - request body
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  /// 
  /// [path] - endpoint path
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }



  /// Handle error dari DioException ke AppException
  AppException _handleError(DioException error) {
    print('❌ DioException: ${error.type}');
    print('   Message: ${error.message}');

    switch (error.type) {
      // Network tidak tersedia atau timeout
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );

      // Error response dari server (ada status code)
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      // Network error (no internet)
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(
            message: 'No internet connection',
            code: 'NO_INTERNET',
          );
        }
        return ApiException(
          message: 'Unknown error: ${error.message}',
          code: 'UNKNOWN',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled',
          code: 'CANCELLED',
        );



      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Connection error. Please try again.',
          code: 'CONNECTION_ERROR',
        );

      // Certificate error
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Certificate error',
          code: 'BAD_CERTIFICATE',
        );
    }
  }

  /// Handle HTTP error responses (4xx, 5xx)
  AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    print('   Status Code: $statusCode');
    print('   Response: $data');

    // Extract error message dari response
    String errorMessage = 'Something went wrong';
    if (data is Map<String, dynamic>) {
      errorMessage = data['message'] ?? data['error'] ?? errorMessage;
    }

    // Handle berbagai status code
    switch (statusCode) {
      case 400:
        // Validation error
        return ValidationException(
          message: errorMessage,
          errors: _extractFieldErrors(data),
          code: 'VALIDATION_ERROR',
        );

      case 401:
      case 403:
        // Authentication/Permission error
        return AuthException(
          message: errorMessage,
          code: 'UNAUTHORIZED',
        );

      case 404:
        return ApiException(
          message: 'Resource not found',
          code: 'NOT_FOUND',
          statusCode: statusCode,
        );

      case 500:
      case 502:
      case 503:
        // Server error
        return ServerException(
          message: errorMessage,
          code: 'SERVER_ERROR',
        );

      default:
        return ApiException(
          message: errorMessage,
          code: 'API_ERROR',
          statusCode: statusCode,
          responseData: data,
        );
    }
  }

  /// Extract field-level errors dari validation response
  /// 
  /// Contoh response format:
  /// { "errors": { "email": "Email is required", "password": "Too short" } }
  Map<String, String>? _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.cast<String, String>();
      }
    }
    return null;
  }
}

/// Dio Interceptor untuk logging dan error handling
class _ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('');
    print('🚀 [${options.method}] ${options.baseUrl}${options.path}');

    if (options.queryParameters.isNotEmpty) {
      print('   Query: ${options.queryParameters}');
    }

    if (options.data != null) {
      print('   Body: ${options.data}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ [${response.statusCode}] Success');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ Error: ${err.type}');

    handler.next(err);
  }
}


