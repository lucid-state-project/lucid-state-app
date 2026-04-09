import 'package:lucid_state_app/data/models/auth_models.dart';
import 'package:lucid_state_app/data/repositories/auth_repository.dart';

/// Base use case class
/// 
/// Semua use case harus extend class ini untuk consistent error handling
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// ============================================================================
// AUTH USE CASES
// ============================================================================

/// Use case untuk guest login
/// 
/// Panggilnya: await GuestLoginUseCase(repository).call(GuestLoginParams())
class GuestLoginUseCase extends UseCase<AuthResponse, GuestLoginParams> {
  final AuthRepository repository;

  GuestLoginUseCase(this.repository);

  /// Execute guest login
  /// 
  /// [params] - GuestLoginParams (optional guestId)
  /// Returns: AuthResponse dengan guest token
  /// Throws: AppException jika ada error
  @override
  Future<AuthResponse> call(GuestLoginParams params) async {
    return repository.loginAsGuest(guestId: params.guestId);
  }
}

/// Parameters untuk guest login
class GuestLoginParams {
  final String? guestId;

  GuestLoginParams({this.guestId});
}

// ============================================================================

/// Use case untuk login dengan email & password
/// 
/// Panggilnya: await LoginUseCase(repository).call(LoginParams(...))
class LoginUseCase extends UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute user login
  /// 
  /// [params] - LoginParams (email, password)
  /// Returns: AuthResponse dengan access token
  /// Throws: AppException jika ada error
  @override
  Future<AuthResponse> call(LoginParams params) async {
    return repository.login(params.email, params.password);
  }
}

/// Parameters untuk login
class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}

// ============================================================================

/// Use case untuk register user baru atau upgrade guest
/// 
/// Panggilnya: await RegisterUseCase(repository).call(RegisterParams(...))
class RegisterUseCase extends UseCase<AuthResponse, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Execute user registration
  /// 
  /// [params] - RegisterParams (email, username, password, optional userId untuk upgrade guest)
  /// Returns: AuthResponse dengan user_id
  /// Throws: AppException / ValidationException jika ada error
  @override
  Future<AuthResponse> call(RegisterParams params) async {
    return repository.register(
      email: params.email,
      username: params.username,
      password: params.password,
      userId: params.userId,
    );
  }
}

/// Parameters untuk register
/// 
/// Mendukung dua use case:
/// 1. Register user baru: RegisterParams(email: ..., username: ..., password: ...)
/// 2. Upgrade guest: RegisterParams(email: ..., username: ..., password: ..., userId: guestId)
class RegisterParams {
  /// User ID jika ini upgrade dari guest account
  final String? userId;
  
  /// Username untuk akun baru atau upgrade
  final String username;
  
  /// Email
  final String email;
  
  /// Password
  final String password;

  RegisterParams({
    this.userId,
    required this.username,
    required this.email,
    required this.password,
  });
}

// ============================================================================

/// Use case untuk logout
/// 
/// Panggilnya: await LogoutUseCase(repository).call(NoParams())
class LogoutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Execute logout
  /// 
  /// Clears token dan notifies backend
  /// Throws: AppException jika ada error
  @override
  Future<void> call(NoParams params) async {
    return repository.logout();
  }
}

// ============================================================================

/// Use case untuk refresh access token
/// 
/// Panggilnya: await RefreshTokenUseCase(repository).call(RefreshTokenParams(...))
class RefreshTokenUseCase extends UseCase<AuthResponse, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  /// Execute token refresh
  /// 
  /// [params] - RefreshTokenParams (refreshToken)
  /// Returns: AuthResponse dengan access token baru
  /// Throws: AppException jika ada error
  @override
  Future<AuthResponse> call(RefreshTokenParams params) async {
    return repository.refreshToken(params.refreshToken);
  }
}

/// Parameters untuk refresh token
class RefreshTokenParams {
  final String refreshToken;

  RefreshTokenParams({required this.refreshToken});
}

// ============================================================================

/// No parameters class
/// 
/// Gunakan ini untuk use case yang tidak perlu parameters
class NoParams {
  const NoParams();
}
