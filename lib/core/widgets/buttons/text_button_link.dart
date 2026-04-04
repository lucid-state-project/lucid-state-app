import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// An inline text button used for navigational links.
///
/// Examples: "Forgot?", "Sign Up", "Sign In"
class TextButtonLink extends StatelessWidget {
  const TextButtonLink({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textStyle,
  });

  /// Button label text.
  final String text;

  /// Callback when tapped.
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
