import '../../core/api/api_client.dart';
import '../../core/api/config.dart';
import '../../core/api/exceptions.dart';
import '../../core/services/local_storage_service.dart';
import '../models/auth_models.dart';

/// Repository pattern untuk authentication
/// 
/// Memisahkan business logic dari presentation layer
/// Menangani semua API calls yang berhubungan dengan auth
abstract class AuthRepository {
  /// Guest login - tanpa perlu email/password
  Future<AuthResponse> loginAsGuest({String? guestId});

  /// User login dengan email & password
  Future<AuthResponse> login(String email, String password);

  /// User register
  /// 
  /// Dua use case:
  /// 1. Register user baru: register(email, username, password)
  /// 2. Upgrade guest account: register(email, username, password, userId: guestUserId)
  Future<AuthResponse> register({
    required String email,
    required String username,
    required String password,
    String? userId,
  });

  /// Logout
  Future<void> logout();

  /// Refresh access token dengan refresh token
  Future<AuthResponse> refreshToken(String token);
}

/// Implementasi repository
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  /// Guest login - tanpa perlu login
  /// 
  /// Endpoint: POST /auth/guest?userId={optional-user-id}
  /// Query Param: userId - optional existing user_id untuk reuse account
  /// Response: AuthResponse dengan guest token & user_id
  /// 
  /// Flow:
  /// 1. Check if userId sudah ada di local storage
  /// 2. Jika ada, pass sebagai query param (untuk reuse existing account)
  /// 3. Jika tidak ada, buat baru (userId akan null, API akan generate user_id baru)
  /// 4. Save user_id dari response ke local storage
  @override
  Future<AuthResponse> loginAsGuest({String? guestId}) async {
    try {
      final localStorage = LocalStorageService();
      
      // 🔍 Diagnose: cek apakah storage sudah initialized
      final hasGuestId = localStorage.hasGuestUserId();
      print('🔍 DEBUG: hasGuestUserId = $hasGuestId');
      
      // Ambil existing guest user_id jika ada
      final savedUserId = localStorage.getGuestUserId();
      print('🔍 DEBUG: savedUserId = $savedUserId');
      
      // Build query params (bukan body!)
      final userId = guestId ?? savedUserId;
      final Map<String, dynamic> queryParams = userId != null ? {'userId': userId} : {};
      
      print('📨 Guest login query params: $queryParams');
      
      final response = await _apiClient.post(
        AppConfig.authGuest,
        queryParams: queryParams,
      );

      // ✅ Parse response - handle berbagai format
      if (response.data != null) {
        final data = response.data is Map<String, dynamic> 
            ? response.data 
            : response.data['data'] ?? response.data;

        if (data is Map<String, dynamic>) {
          final authResponse = AuthResponse.fromJson(data);
          print('✅ Guest login response: ${authResponse.toString()}');
          
          // 💾 Save user_id ke local storage untuk request berikutnya
          await localStorage.saveGuestUserId(authResponse.userId);
          
          // 🔍 Verify: Cek apakah save berhasil
          final verifyUserId = localStorage.getGuestUserId();
          print('🔍 VERIFY: Saved userId = ${authResponse.userId}');
          print('🔍 VERIFY: Retrieved userId = $verifyUserId');
          print('🔍 VERIFY: Save successful? ${verifyUserId == authResponse.userId}');
          
          return authResponse;
        }
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Guest login error: $e');
      rethrow; // Biarkan exception asli terminate
    }
  }

  /// User login dengan email & password
  /// 
  /// Endpoint: POST /auth/login
  /// Body: { "email": "user@example.com", "password": "password" }
  /// Response: AuthResponse dengan access token
  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _apiClient.post(
        AppConfig.authLogin,
        data: request.toJson(),
      );

      // ✅ Parse response - handle berbagai format
      if (response.data != null) {
        final data = response.data is Map<String, dynamic> 
            ? response.data 
            : response.data['data'] ?? response.data;

        if (data is Map<String, dynamic>) {
          final authResponse = AuthResponse.fromJson(data);
          print('✅ Login response: ${authResponse.toString()}');
          return authResponse;
        }
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// User register
  /// 
  /// Endpoint: POST /auth/register
  /// Use case 1 (New user): { "email": "user@example.com", "username": "user123", "password": "pass" }
  /// Use case 2 (Upgrade guest): { "user_id": "guest-id", "email": "user@example.com", "username": "user123", "password": "pass" }
  /// Response: AuthResponse dengan user_id
  @override
  Future<AuthResponse> register({
    required String email,
    required String username,
    required String password,
    String? userId,
  }) async {
    try {
      final request = RegisterRequest(
        userId: userId,
        username: username,
        email: email,
        password: password,
      );

      final response = await _apiClient.post(
        AppConfig.authRegister,
        data: request.toJson(),
      );

      // ✅ Parse response - handle berbagai format
      if (response.data != null) {
        final data = response.data is Map<String, dynamic> 
            ? response.data 
            : response.data['data'] ?? response.data;

        if (data is Map<String, dynamic>) {
          final authResponse = AuthResponse.fromJson(data);
          print('✅ Register response: ${authResponse.toString()}');
          return authResponse;
        }
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  /// Logout
  /// 
  /// Endpoint: POST /auth/logout
  @override
  Future<void> logout() async {
    try {
      final response = await _apiClient.post(AppConfig.authLogout);

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Logout failed',
          code: 'LOGOUT_FAILED',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }

  /// Refresh access token
  /// 
  /// Endpoint: POST /auth/refresh-token
  /// Body: { "refreshToken": "token" }
  /// Response: AuthResponse dengan access token baru
  @override
  Future<AuthResponse> refreshToken(String token) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authRefreshToken,
        data: {'refreshToken': token},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic> 
            ? response.data 
            : response.data['data'] ?? response.data;

        final authResponse = AuthResponse.fromJson(data);
        return authResponse;
      }

      throw ApiException(
        message: 'Token refresh failed',
        code: 'TOKEN_REFRESH_FAILED',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Token refresh error: $e');
      rethrow;
    }
  }
}
