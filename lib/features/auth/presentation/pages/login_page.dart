import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/index.dart';
import 'package:lucid_state_app/core/api/exceptions.dart';
import 'package:lucid_state_app/core/services/local_storage_service.dart';
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

  @override
  void initState() {
    super.initState();
    // ── Initialize repository dan use cases
    _authRepository = AuthRepositoryImpl();
    _loginUseCase = LoginUseCase(_authRepository);
    _guestLoginUseCase = GuestLoginUseCase(_authRepository);
    
    // ── Initialize local storage untuk guest user_id persistence
    _initializeLocalStorage();
  }

  /// Initialize local storage service
  /// Harus di-call sekali saat app startup
  Future<void> _initializeLocalStorage() async {
    try {
      await LocalStorageService().init();
      print('✅ Local storage initialized');
    } catch (e) {
      print('❌ Error initializing local storage: $e');
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
