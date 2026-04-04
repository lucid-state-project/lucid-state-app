import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/index.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please agree to the Terms & Conditions and Privacy Policy',
            ),
          ),
        );
        return;
      }
      context.go(AppRoutes.dashboard);
    }
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
                      // Full Name field
                      AppTextField(
                        label: 'FULL NAME',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
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
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Confirm Password field
                      AppTextField(
                        label: 'CONFIRM PASSWORD',
                        hint: 'Confirm your password',
                        prefixIcon: Icons.lock_outline,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onCreateAccount(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
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
                        onPressed: _onCreateAccount,
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
