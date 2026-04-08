import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/constants/app_spacing.dart';

/// An inline text button used for navigational links.
///
/// Useful for actions like "Forgot?", "Sign Up", "Sign In", and other
/// text-based navigation elements. Minimal padding and tap target size.
///
/// Example:
/// ```dart
/// TextButtonLink(
///   text: 'Forgot Password?',
///   onPressed: _handleForgotPassword,
/// )
/// ```
class TextButtonLink extends StatelessWidget {
  /// Creates a text link button.
  const TextButtonLink({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textStyle,
  });

  /// Button label text.
  final String text;

  /// Callback when tapped. Set to null to disable the button.
  final VoidCallback? onPressed;

  /// Text color. Defaults to [AppColors.primary].
  final Color color;

  /// Override the default text style.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs / 2,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: (textStyle ?? AppTextStyles.labelLarge).copyWith(color: color),
      ),
    );
  }
}
