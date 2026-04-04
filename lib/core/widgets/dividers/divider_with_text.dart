import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A horizontal divider with centred text.
///
/// Commonly used between a primary action and alternative sign-in options:
/// ```
/// ─────────── OR CONTINUE WITH ───────────
/// ```
///
/// Example:
/// ```dart
/// DividerWithText(text: 'OR CONTINUE WITH')
/// ```
class DividerWithText extends StatelessWidget {
  const DividerWithText({
    super.key,
    required this.text,
    this.color = AppColors.divider,
    this.textColor = AppColors.textSecondary,
    this.thickness = 1.0,
    this.textStyle,
  });

  /// The label displayed in the middle of the divider.
  final String text;

  /// Color of the divider lines.
  final Color color;

  /// Color of the label text.
  final Color textColor;

  /// Thickness of the divider lines.
  final double thickness;

  /// Override for the label text style.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final dividerLine = Expanded(
      child: Divider(color: color, thickness: thickness),
    );

    return Row(
      children: [
        dividerLine,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: (textStyle ?? AppTextStyles.labelSmall).copyWith(
              color: textColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
        dividerLine,
      ],
    );
  }
}
