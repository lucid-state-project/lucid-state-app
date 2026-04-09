/// BACKEND INTEGRATION - SETUP & USAGE GUIDE
/// 
/// ============================================================================
/// DIRECTORY STRUCTURE
/// ============================================================================
/// 
/// lib/
/// ├── core/
/// │   ├── api/                    # API Layer
/// │   │   ├── config.dart        # API configuration & endpoints
/// │   │   ├── api_client.dart    # HTTP client (singleton)
/// │   │   └── exceptions.dart    # Custom exceptions
/// │   └── ...
/// │
/// ├── data/                       # Data Layer
/// │   ├── models/                # Request/Response models
/// │   │   └── auth_models.dart
/// │   └── repositories/          # Repository implementations
/// │       └── auth_repository.dart
/// │
/// ├── domain/                     # Business Logic Layer
/// │   └── usecases/              # Use cases
/// │       └── auth_usecases.dart
/// │
/// └── features/
///     └── ...
///
/// ============================================================================
/// ARCHITECTURE LAYERS
/// ============================================================================
/// 
/// 1. PRESENTATION LAYER (Features/Pages)
///    ↓ (depends on)
/// 2. DOMAIN LAYER (Use Cases)
///    ↓ (depends on)
/// 3. DATA LAYER (Repositories + Models)
///    ↓ (depends on)
/// 4. CORE LAYER (API Client + Exceptions)
///
/// This separation ensures:
/// - Easy testing (mock repositories)
/// - Reusability (use cases dapat digunakan di berbagai pages)
/// - Maintainability (perubahan API logic terisolasi di data layer)
///
/// ============================================================================
/// QUICK START
/// ============================================================================
///
/// 1. UPDATE API ENDPOINT
///    File: lib/core/api/config.dart
///    
///    static const String baseUrl = 'http://localhost:8081';
///
/// 2. INITIALIZE REPOSITORY
///    File: lib/features/auth/presentation/pages/login_page.dart
///    
///    final authRepository = AuthRepositoryImpl();
///    final loginUseCase = LoginUseCase(authRepository);
///
/// 3. CALL USE CASE
///    
///    try {
///      final authResponse = await loginUseCase.call(
///        LoginParams(email: 'user@example.com', password: 'password'),
///      );
///      // Success: authResponse.accessToken, authResponse.userId, etc
///      print('✅ Login successful: ${authResponse.email}');
///    } catch (e) {
///      if (e is ValidationException) {
///        // Handle validation errors
///        final fieldError = e.getFieldError('email');
///      } else if (e is AuthException) {
///        // Handle auth errors
///      } else {
///        // Handle other errors
///      }
///    }
///
/// ============================================================================
/// API ENDPOINTS & EXAMPLES
/// ============================================================================
///
/// ### Guest Login (Tanpa email/password)
/// 
/// POST http://localhost:8081/auth/guest
/// Content-Type: application/json
///
/// Body (optional guestId):
/// {
///   "guestId": "device-123" (optional)
/// }
///
/// Response (200):
/// {
///   "user_id": "675a50be-d8f4-4d59-9b81-5ee6c87e09b2",
///   "guest": true
/// }
///
/// Usage dalam Flutter:
/// ```dart
/// final guestLoginUseCase = GuestLoginUseCase(repository);
/// final auth = await guestLoginUseCase(GuestLoginParams());
/// print('\u2705 Guest user ID: ${auth.userId}');
/// ```
///
/// ---
///
/// ### User Login (Email + Password)
/// 
/// POST http://localhost:8081/auth/login
/// Content-Type: application/json
///
/// Body:
/// {
///   "email": "user@example.com",
///   "password": "password123"
/// }
///
/// Response (200):
/// {
///   "user_id": "user-456",
///   "email": "user@example.com",
///   "username": "john_doe"
/// }
///
/// Error (400):
/// {
///   "message": "Invalid credentials",
///   "errors": {
///     "email": "Email not found",
///     "password": "Password is incorrect"
///   }
/// }
///
/// Usage dalam Flutter:
/// ```dart
/// final loginUseCase = LoginUseCase(repository);
/// final auth = await loginUseCase(LoginParams(
///   email: 'user@example.com',
///   password: 'password123',
/// ));
/// ```
///
/// ---
///
/// ### User Register (New Account or Upgrade Guest)
/// 
/// POST http://localhost:8081/auth/register
/// Content-Type: application/json
///
/// Use Case 1 - Register New User:
/// {
///   "username": "john_doe",
///   "email": "john@example.com",
///   "password": "password123"
/// }
///
/// Use Case 2 - Upgrade Guest Account:
/// {
///   "user_id": "guest-123",
///   "username": "john_doe",
///   "email": "john@example.com",
///   "password": "password123"
/// }
///
/// Response (201):
/// {
///   "user_id": "user-789",
///   "email": "john@example.com",
///   "username": "john_doe"
/// }
///
/// Error (400):
/// {
///   "message": "Validation failed",
///   "errors": {
///     "email": "Email already exists",
///     "password": "Password must be at least 6 characters"
///   }
/// }
///
/// Usage dalam Flutter:
/// ```dart
/// final registerUseCase = RegisterUseCase(repository);
/// 
/// // New user registration
/// final auth = await registerUseCase(RegisterParams(
///   username: 'john_doe',
///   email: 'john@example.com',
///   password: 'password123',
/// ));
/// 
/// // Upgrade guest account
/// final auth = await registerUseCase(RegisterParams(
///   userId: guestUserId, // dari guest login sebelumnya
///   username: 'john_doe',
///   email: 'john@example.com',
///   password: 'password123',
/// ));
/// ```
///
/// ============================================================================
/// ERROR HANDLING
/// ============================================================================
///
/// All API calls throw AppException subtypes:
///
/// - ValidationException
///   Status: 400
///   Contains: field-level validation errors
///   Example: email already exists, password too short
///
/// - AuthException
///   Status: 401, 403
///   Meaning: Invalid token, permission denied, unauthorized
///
/// - ServerException
///   Status: 500, 502, 503
///   Server encountered an error
///
/// - NetworkException
///   Timeout, no internet, connection error
///
/// - ApiException
///   Generic API error
///
/// Example error handling:
/// ```dart
/// try {
///   final auth = await loginUseCase(params);
/// } on ValidationException catch (e) {
///   // Show field errors
///   final emailError = e.getFieldError('email');
///   print('Email error: $emailError');
/// } on AuthException catch (e) {
///   // Show auth error dialog
///   showErrorDialog(e.message);
/// } on NetworkException catch (e) {
///   // Show no internet message
///   showSnackBar('No internet connection');
/// }
/// ```
///
/// ============================================================================
/// AUTHENTICATION TOKEN MANAGEMENT
/// ============================================================================
///
/// After successful login, token is automatically set in headers:
///
/// All subsequent requests will include:
/// Authorization: Bearer <accessToken>
///
/// Manual token operations:
/// ```dart
/// // Set token manually
/// ApiClient().setToken('your-token-here');
///
/// // Clear token (logout)
/// ApiClient().clearToken();
///
/// // Check if authenticated
/// if (ApiClient().isAuthenticated) {
///   // User is logged in
/// }
/// ```
///
/// ============================================================================
/// DEVELOPMENT TIPS
/// ============================================================================
///
/// 1. Enable debug logging:
///    - ApiClient interceptor prints all requests/responses
///    - Watch console for 🚀 (request), ✅ (success), ❌ (error)
///
/// 2. Test with mock server:
///    - Use Postman or insomnia for API testing
///    - Verify response format matches AuthResponse model
///
/// 3. Local testing:
///    - Change baseUrl to: http://localhost:8081
///    - Or use: http://192.168.1.100:8081 (from physical device)
///
/// 4. Production deployment:
///    - Use environment variables or BuildConfig
///    - Store credentials securely (never hardcode)
///    - Use HTTPS in production
///