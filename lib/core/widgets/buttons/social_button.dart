import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A button for social sign-in flows (e.g., "Continue with Google").
///
/// Renders a bordered white pill-shaped button with an optional leading
/// image asset and a label.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconAsset,
    this.iconWidget,
    this.width = double.infinity,
    this.height = 52.0,
    this.borderRadius = 24.0,
  });

  /// Button label text, e.g. "Continue with Google".
  final String text;

  /// Callback when button is tapped. Set to null to disable.
  final VoidCallback? onPressed;

  /// Path to an image asset for the social logo (e.g., Google logo PNG).
  /// Ignored if [iconWidget] is provided.
  final String? iconAsset;

  /// Custom icon widget. Takes precedence over [iconAsset].
  final Widget? iconWidget;

  /// Width of the button.
  final double width;

  /// Height of the button.
  final double height;

  /// Corner radius.
  final double borderRadius;

  Widget? _buildIcon() {
    if (iconWidget != null) return iconWidget;
    if (iconAsset != null) {
      return Image.asset(iconAsset!, width: 24, height: 24);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _buildIcon();

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider, width: 1.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: AppTextStyles.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
