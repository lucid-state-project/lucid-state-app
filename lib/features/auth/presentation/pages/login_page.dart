import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/index.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _onContinueWithGuest() {
    // TODO: Implement Google sign-in
    context.go(AppRoutes.dashboard);
  }

  void _onContinueWithGoogle() {
    // TODO: Implement Google sign-in
    context.go(AppRoutes.dashboard);
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
                        onFieldSubmitted: (_) => _onSignIn(),
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
                        onPressed: _onSignIn,
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      const DividerWithText(text: 'OR CONTINUE WITH'),

                      const SizedBox(height: 24),

                      // Continue with Guest button
                      SecondaryButton(
                        borderColor:  AppColors.primaryLight,
                        text: 'Continue with Guest',
                        textStyle: AppTextStyles.button.copyWith(
                          color: AppColors.primaryLight,
                        ),
                        onPressed: _onContinueWithGuest,
                      ),

                      const SizedBox(height: 24),

                      // Continue with Google button
                      SecondaryButton(
                        text: 'Continue with Google',
                        onPressed: _onContinueWithGoogle,
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
