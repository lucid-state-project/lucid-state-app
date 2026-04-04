import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A secondary (outlined / white background) button.
///
/// Used for alternative actions such as "Continue with Google".
/// Optionally displays a leading icon (e.g., a social logo).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 52.0,
    this.borderRadius = 24.0,
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

  /// Width of the button. Defaults to [double.infinity] (full width).
  final double width;

  /// Height of the button.
  final double height;

  /// Corner radius of the button.
  final double borderRadius;

  /// Button background color.
  final Color backgroundColor;

  /// Button foreground (text/icon) color.
  final Color foregroundColor;

  /// Border color.
  final Color borderColor;

  /// Border stroke width.
  final double borderWidth;

  /// Override the default button label text style.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: (textStyle ?? AppTextStyles.button).copyWith(
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
