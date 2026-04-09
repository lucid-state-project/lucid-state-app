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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ── Form & Controllers
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── Repository & Use Cases
  late final AuthRepository _authRepository;
  late final RegisterUseCase _registerUseCase;

  // ── State
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl();
    _registerUseCase = RegisterUseCase(_authRepository);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle user registration via API
  /// 
  /// Flow:
  /// 1. Check jika ada saved guest user_id (dari guest login sebelumnya)
  /// 2. Jika ada, pass sebagai userId untuk UPGRADE dari guest account
  /// 3. Jika tidak ada, register sebagai user baru biasa
  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_agreedToTerms) {
      _showErrorSnackBar('Please agree to the Terms & Conditions and Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔍 Check apakah ada saved guest user_id
      final localStorage = LocalStorageService();
      final savedGuestUserId = localStorage.getGuestUserId();
      
      if (savedGuestUserId != null) {
        print('♻️ Upgrading guest account: $savedGuestUserId');
      } else {
        print('🆕 Register as new user');
      }

      final authResponse = await _registerUseCase.call(
        RegisterParams(
          userId: savedGuestUserId,  // ← Akan null jika user baru, atau guest UUID jika upgrade
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (mounted) {
        print('✅ Registration successful: ${authResponse.email}');
        
        // 🗑️ Clear saved guest user_id setelah upgrade berhasil
        if (savedGuestUserId != null) {
          await localStorage.clearGuestUserId();
        }
        
        context.go(AppRoutes.dashboard);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } on NetworkException {
      if (mounted) {
        _showErrorSnackBar('No internet connection. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        print('\u274c Register error: $e');
        print('Stack trace: ${StackTrace.current}');
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──────────────────────────────────────────────
                _buildHeader(),

                const SizedBox(height: 32),

                // ── Form Card ────────────────────────────────────────────
                AppCard(
                  borderRadius: 32,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Join the Flow',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.normal,
                          fontSize: 30
                        ),
                      ),

                       const SizedBox(height: 12),
  // Subtitle
                      Text(
                        'Begin your journey toward mental clarity and deep observation.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                       const SizedBox(height: 24),
  // Subtitle
                      // Username field
                      AppTextField(
                        label: 'USERNAME',
                        hint: 'Choose your username',
                        prefixIcon: Icons.person_outline,
                        controller: _usernameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

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
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password field
                      AppTextField(
                        label: 'PASSWORD',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRegister(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Terms & Conditions checkbox
                      AppCheckbox(
                        value: _agreedToTerms,
                        onChanged: (v) =>
                            setState(() => _agreedToTerms = v ?? false),
                        label:
                            'I agree to the Terms & Conditions and Privacy Policy',
                        links: [
                          AppCheckboxLabelLink(
                            text: 'Terms & Conditions',
                            color: AppColors.primaryLight,
                            onTap: () {
                              // TODO: Open terms & conditions
                            },
                          ),
                          AppCheckboxLabelLink(
                            text: 'Privacy Policy',
                            color: AppColors.primaryLight,
                            onTap: () {
                              // TODO: Open privacy policy
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // CREATE ACCOUNT button
                      PrimaryButton(
                        text: 'CREATE ACCOUNT',
                        onPressed: _handleRegister,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Sign In link ──────────────────────────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButtonLink(
                        text: 'Sign In',
                        color: AppColors.primaryLight,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "LucidState" brand with underline
        Container(
  width: double.infinity,
  alignment: Alignment.center,
  child: Text('LucidState',
          style: AppTextStyles.heading2Italic.copyWith(
            color: AppColors.primaryDark,
            decorationColor: AppColors.primaryDark,
            decorationThickness: 2,
          ),),
        ),
        const SizedBox(height: 8),
        // garis pendek tengah
        Center(
            child: Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppColors.primaryDark.value),
                    Color(AppColors.primaryLight.value),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );
  }
}
