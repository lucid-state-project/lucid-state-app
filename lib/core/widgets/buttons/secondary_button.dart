import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/constants/app_spacing.dart';

/// A versatile secondary button with optional icon support.
///
/// Renders an outlined button with customizable styling. Can display
/// a leading widget (icon or image) and supports both social and
/// regular secondary actions.
///
/// Example:
/// ```dart
/// SecondaryButton(
///   text: 'Continue with Google',
///   onPressed: _handleGoogleSignIn,
///   icon: Image.asset('assets/icons/google.png'),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconAsset,
    this.width = double.infinity,
    this.height = 52.0,
    this.borderRadius = AppSpacing.radiusXl,
    this.backgroundColor = AppColors.surface,
    this.foregroundColor = AppColors.textPrimary,
    this.borderColor = AppColors.divider,
    this.borderWidth = 1.5,
    this.textStyle,
  });

  /// Button label text.
  final String text;

  /// Callback when button is tapped. Set to null to disable.
  final VoidCallback? onPressed;

  /// Optional leading widget (e.g., an [Image] or [Icon]).
  final Widget? icon;

  /// Optional path to image asset (e.g., for social logos).
  /// Ignored if [icon] is provided.
  final String? iconAsset;

  /// Width of the button. Defaults to [double.infinity] (full width).
  final double width;

  /// Height of the button. Defaults to 52.0.
  final double height;

  /// Corner radius of the button. Defaults to [AppSpacing.radiusXl].
  final double borderRadius;

  /// Button background color. Defaults to [AppColors.surface].
  final Color backgroundColor;

  /// Button foreground (text/icon) color. Defaults to [AppColors.textPrimary].
  final Color foregroundColor;

  /// Border color. Defaults to [AppColors.divider].
  final Color borderColor;

  /// Border stroke width. Defaults to 1.5.
  final double borderWidth;

  /// Override the default button label text style.
  final TextStyle? textStyle;

  /// Builds the leading icon widget.
  Widget? _buildIcon() {
    if (icon != null) return icon;
    if (iconAsset != null) {
      return Image.asset(iconAsset!, width: 24, height: 24);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final leadingIcon = _buildIcon();

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor, width: borderWidth),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: AppSpacing.paddingHorizontalLg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon,
              const SizedBox(width: AppSpacing.md),
            ],
            Text(
              text,
              style: textStyle ?? AppTextStyles.button.copyWith(
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
