import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/core/constants/app_spacing.dart';

/// Primary action button with gradient background.
///
/// Features a gradient from dark blue to purple with support for
/// loading state display.
///
/// Example:
/// ```dart
/// PrimaryButton(
///   text: 'Sign In',
///   onPressed: _handleSignIn,
///   isLoading: _isLoading,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  /// Creates a primary button.
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.borderRadius = AppSpacing.radiusXl,
  });

  /// Button label text.
  final String text;

  /// Callback when button is tapped.
  final VoidCallback onPressed;

  /// Whether the button is in loading state. Shows spinner instead of text.
  final bool isLoading;

  /// Button width. Defaults to [double.infinity] if not specified.
  final double? width;

  /// Button height. Defaults to 56.
  final double height;

  /// Corner radius. Defaults to [AppSpacing.radiusXl].
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(AppColors.primaryDark.value), // Dark blue
            Color(AppColors.primaryLight.value), // Purple
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}