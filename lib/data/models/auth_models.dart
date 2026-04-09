/// Model untuk API response yang generic
/// 
/// Semua response dari backend mengikuti format ini
class ApiResponse<T> {
  /// HTTP status code
  final int statusCode;

  /// Success/Error message
  final String message;

  /// Data payload
  final T? data;

  /// Is request successful
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
    required this.success,
  });

  /// Factory untuk parse dari JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return ApiResponse(
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? 'Success',
      data: dataParser != null ? dataParser(json['data']) : null,
      success: json['success'] ?? true,
    );
  }

  @override
  String toString() => 'ApiResponse(status: $statusCode, success: $success, message: $message)';
}

// ============================================================================
// AUTH MODELS
// ============================================================================

/// Request untuk guest login
/// 
/// Endpoint: POST /auth/guest?userId={optional-user-id}
/// Parameter: userId (query param) - optional existing user_id untuk reuse account
/// Note: Tidak ada body, parameter dikirim via URL query string
class GuestLoginRequest {
  /// Optional: existing user ID untuk reuse account
  final String? userId;

  GuestLoginRequest({
    this.userId,
  });

  /// Tidak digunakan lagi - parameter dikirim via query string
  /// Kept untuk backward compatibility
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
    };
  }
}

/// Request untuk user login
/// 
/// Endpoint: POST /auth/login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Request untuk user register
/// 
/// Endpoint: POST /auth/register
/// Dua use case:
/// 1. Register user baru (tanpa user_id)
/// 2. Upgrade guest account (dengan user_id)
class RegisterRequest {
  /// User ID (jika upgrade dari guest account)
  final String? userId;
  
  /// Username untuk akun baru atau upgrade
  final String username;
  
  /// Email untuk akun baru atau upgrade
  final String email;
  
  /// Password
  final String password;

  RegisterRequest({
    this.userId,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,  // ← Consistent with API spec
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

/// Response dari auth endpoints
/// 
/// Berisi user data dari server
/// - Guest login response: { user_id, guest }
/// - User login/register response: { user_id, username, email }
class AuthResponse {
  /// User ID dari server
  final String userId;

  /// Username (optional untuk guest)
  final String? username;

  /// User email (optional untuk guest)
  final String? email;
  
  /// Flag apakah ini guest account
  final bool? isGuest;

  AuthResponse({
    required this.userId,
    this.username,
    this.email,
    this.isGuest,
  });

  /// Factory untuk parse dari JSON response
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] ?? json['userId'] ?? json['id'] ?? '',
      username: json['username'] ?? json['name'] ?? json['displayName'],
      email: json['email'],
      isGuest: json['guest'] ?? false,
    );
  }

  /// Convert ke JSON untuk local storage
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (isGuest != null) 'guest': isGuest,
    };
  }

  @override
  String toString() => 'AuthResponse(userId: $userId, username: $username, email: $email, isGuest: $isGuest)';
}
