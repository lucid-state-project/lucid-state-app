import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/index.dart';
import 'package:lucid_state_app/core/api/exceptions.dart';
import 'package:lucid_state_app/core/services/local_storage_service.dart';
import 'package:lucid_state_app/core/constants/dev_constants.dart';
import 'package:lucid_state_app/data/repositories/auth_repository.dart';
import 'package:lucid_state_app/domain/usecases/auth_usecases.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ── Form & Controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── Repository & Use Cases
  late final AuthRepository _authRepository;
  late final LoginUseCase _loginUseCase;
  late final GuestLoginUseCase _guestLoginUseCase;

  // ── Loading & Error States
  bool _isLoadingLogin = false;
  bool _isLoadingGuest = false;
  
  // ── Auto-login state (development only)
  bool _autoLoginAttempted = false;

  @override
  void initState() {
    super.initState();
    // ── Initialize repository dan use cases
    _authRepository = AuthRepositoryImpl();
    _loginUseCase = LoginUseCase(_authRepository);
    _guestLoginUseCase = GuestLoginUseCase(_authRepository);
    
    // ── Initialize local storage & setup fixed guest account
    _initializeLocalStorageWithFixedGuest();
  }

  /// 🔧 Initialize local storage dan pre-set fixed guest account
  /// 
  /// Flow:
  /// 1. Initialize LocalStorageService (singleton)
  /// 2. Pre-set fixed UUID dan username dari DevConstants
  ///    └─ Saat app startup, storage akan punya ini untuk guest login
  /// 3. Trigger auto-login setelah delay (jika enabled)
  ///
  /// This ensures:
  /// - Guest login always reuse same UUID (tidak create user baru)
  /// - Same account setiap app restart
  /// - Same account ketika user click "Continue as Guest"
  Future<void> _initializeLocalStorageWithFixedGuest() async {
    try {
      final localStorage = LocalStorageService();
      
      // ✅ Initialize storage service
      await localStorage.init();
      print('✅ Local storage initialized');
      
      // 💾 PRE-SET: Save fixed guest UUID dan username
      // Ini akan di-reuse oleh guest login (tidak create user baru)
      print('💾 PRE-SETTING fixed guest account:');
      print('   └─ UUID: ${DevConstants.fixedGuestUuid}');
      print('   └─ Username: ${DevConstants.fixedGuestUsername}');
      
      await localStorage.saveGuestUserId(DevConstants.fixedGuestUuid);
      await localStorage.saveUsername(DevConstants.fixedGuestUsername);
      
      print('✅ Fixed guest account set to local storage');
      
      // 🚀 TRIGGER AUTO-LOGIN (setelah delay)
      // 
      // Check if auto-login enabled di config
      // Jika ya, schedule auto-login dengan delay untuk UI ready
      if (DevConstants.enableAutoLogin && !_autoLoginAttempted) {
        Future.delayed(
          Duration(milliseconds: DevConstants.autoLoginDelayMs),
          () {
            if (mounted) {
              print('🚀 AUTO-LOGIN TRIGGER: Performing guest login...');
              _performAutoLogin();
            }
          },
        );
      }
    } catch (e) {
      print('❌ Error initializing local storage: $e');
    }
  }

  /// 🚀 AUTO-LOGIN METHOD (Development Only - GUEST LOGIN)
  /// 
  /// Step-by-step flow:
  /// 1. Mark attempt (prevent duplicate auto-login calls)
  /// 2. Set loading state untuk show progress
  /// 3. Call guest login use case (tidak perlu credentials)
  /// 4. Guest login akan:
  ///    a. Check local storage untuk UUID
  ///    b. Find UUID: 989c6b32-f32a-4ffb-8702-06f007e0aeeb (pre-set)
  ///    c. POST /auth/guest?userId={uuid}
  ///    d. API recognize UUID, reuse account (NOT create new)
  ///    e. Return account data
  /// 5. Success → Navigate ke Dashboard
  /// 6. Error → Show message, tetap di login page
  /// 7. Finally → Reset loading state
  /// 
  /// ⚠️ IMPORTANT:
  /// - UUID sudah pre-set di local storage di initState
  /// - Guest login akan pick up UUID dari storage
  /// - Same account everytime (baik auto-login atau manual click "Continue as Guest")
  /// - mounted check untuk prevent setState after dispose
  Future<void> _performAutoLogin() async {
    // 🔄 Mark bahwa auto-login attempt sudah dilakukan
    _autoLoginAttempted = true;
    
    setState(() {
      _isLoadingLogin = true;
    });

    try {
      print('🚀 AUTO-LOGIN EXECUTING:');
      print('   Step 1: Guest login akan pick UUID dari local storage');
      print('   Step 2: POST /auth/guest?userId=989c6b32-f32a-4ffb-8702-06f007e0aeeb');
      print('   Step 3: API reuse same account');
      
      // 📨 Call guest login (akan pick up pre-set UUID dari storage)
      final authResponse = await _guestLoginUseCase.call(
        GuestLoginParams(),
      );

      if (mounted) {
        print('✅ AUTO-LOGIN SUCCESSFUL');
        print('   └─ Guest UUID: ${authResponse.userId}');
        print('   └─ Is Guest: ${authResponse.isGuest}');
        print('   └─ Username: ${authResponse.username}');
        
        // 🧭 Navigate ke Dashboard
        context.go(AppRoutes.dashboard);
      }
    } on ValidationException catch (e) {
      // ⚠️ Validation error
      if (mounted) {
        print('❌ AUTO-LOGIN VALIDATION ERROR: ${e.message}');
        _showErrorSnackBar('Validation Error: ${e.message}');
      }
    } on AuthException catch (e) {
      // ⚠️ Auth error
      if (mounted) {
        print('❌ AUTO-LOGIN AUTH ERROR: ${e.message}');
        _showErrorSnackBar('Auth Error: ${e.message}');
      }
    } on NetworkException catch (e) {
      // ⚠️ Network error
      if (mounted) {
        print('❌ AUTO-LOGIN NETWORK ERROR: ${e.message}');
        _showErrorSnackBar('Network Error: ${e.message}');
      }
    } catch (e) {
      // ⚠️ Unknown error
      if (mounted) {
        print('❌ AUTO-LOGIN UNKNOWN ERROR: $e');
        print('Stack trace: ${StackTrace.current}');
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      // 🔄 Reset loading state
      if (mounted) {
        setState(() {
          _isLoadingLogin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login dengan email & password
  /// Validasi form → Call API (/auth/login) → Navigate ke dashboard
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoadingLogin = true;
    });

    try {
      final authResponse = await _loginUseCase.call(
        LoginParams(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (mounted) {
        print('✅ Login successful: ${authResponse.email}');
        context.go(AppRoutes.dashboard);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        // Field errors: e.errors contains field-specific error messages
        _showErrorSnackBar(e.message);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } on NetworkException catch (e) {
      if (mounted) {
        _showErrorSnackBar('Network error: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        print('\u274c Login error: $e');
        print('Stack trace: ${StackTrace.current}');
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLogin = false;
        });
      }
    }
  }

  /// Handle guest login (POST /auth/guest)
  /// 
  /// Flow:
  /// 1. Check apakah sudah ada saved guest user_id
  /// 2. Jika ada → kirim ke API (untuk reuse existing account)
  /// 3. Jika tidak ada → kirim request kosong (API generate user_id baru)
  /// 4. Save user_id dari response ke local storage
  /// 5. Navigate ke dashboard
  Future<void> _handleGuestLogin() async {
    setState(() {
      _isLoadingGuest = true;
    });

    try {
      final authResponse = await _guestLoginUseCase.call(
        GuestLoginParams(),
      );

      if (mounted) {
        print('✅ Guest login successful');
        print('   └─ User ID: ${authResponse.userId}');
        print('   └─ Is Guest: ${authResponse.isGuest}');
        context.go(AppRoutes.dashboard);
      }
    } on NetworkException {
      if (mounted) {
        _showErrorSnackBar('No internet connection');
      }
    } catch (e) {
      if (mounted) {
        print('❌ Error: $e');
        _showErrorSnackBar('Failed to login as guest');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGuest = false;
        });
      }
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // ── Logo / Header ─────────────────────────────────────────
                _buildLogo(),

                const SizedBox(height: 40),

                // ── Form Card ─────────────────────────────────────────────
                AppCard(
                  borderRadius: 32,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email field
                      AppTextField(
                        label: 'EMAIL ADDRESS',
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password label row with "Forgot?" link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PASSWORD',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButtonLink(
                            text: 'Forgot?',
                            color: AppColors.primaryLight,
                            onPressed: null, // inactive for now
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // Sign In button
                      PrimaryButton(
                        text: 'Sign In',
                        onPressed: _handleLogin,
                        isLoading: _isLoadingLogin,
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      const DividerWithText(text: 'OR CONTINUE WITH'),

                      const SizedBox(height: 24),

                      // Continue with Guest button
                      SecondaryButton(
                        text: 'Continue as Guest',
                        onPressed: _isLoadingGuest ? null : _handleGuestLogin,
                        icon: _isLoadingGuest
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : const Icon(Icons.person_outline),
                      ),

                      const SizedBox(height: 24),

                      // Continue with Google button (TODO)
                      SecondaryButton(
                        text: 'Continue with Google',
                        onPressed: () {
                          _showErrorSnackBar('Google login coming soon');
                        },
                        icon: Image.asset(
                          'assets/icons/login/SVG.png',
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Sign Up link ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButtonLink(
                      text: 'Sign Up',
                      color: AppColors.primaryLight,
                      onPressed: () => context.go(AppRoutes.register),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Footer badges ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(Icons.lock_outline, 'ENCRYPTED'),
                    const SizedBox(width: 20),
                    _buildBadge(Icons.cloud_outlined, 'CLOUD SYNC'),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Square logo tile
      Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [
        Color(AppColors.primaryDark.value),
        Color(AppColors.primaryLight.value),
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ),
  child: Center(
    child: Padding(
      padding: const EdgeInsets.all(2), // biar ada jarak kayak design
      child: Image.asset(
        'assets/images/Logo.png',
        fit: BoxFit.contain, // penting!
      ),
    ),
  ),
),
        const SizedBox(height: 14),
        Text(
          'LUCID',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primaryDark,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'STATE OF MIND',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
