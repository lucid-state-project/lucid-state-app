import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A full-width primary button with the app's purple brand color.
///
/// Used for primary actions like "Sign In", "Create Account".
/// Supports a loading state that disables the button and shows a spinner.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 52.0,
    this.borderRadius = 24.0,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.textStyle,
  });

  /// Button label text.
  final String text;

  /// Callback when button is tapped. Set to null to disable.
  final VoidCallback? onPressed;

  /// When true, replaces the label with a circular progress indicator
  /// and disables the tap handler.
  final bool isLoading;

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

  /// Override the default button label text style.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: Colors.white60,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Text(
                text,
                style: (textStyle ?? AppTextStyles.button).copyWith(
                  color: foregroundColor,
                ),
              ),
      ),
    );
  }
}
