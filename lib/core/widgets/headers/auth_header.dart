import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A header widget for authentication screens.
///
/// Renders an optional logo asset above a bold title and a softer subtitle.
/// The logo is shown only when [logoAsset] is provided.
///
/// Example:
/// ```dart
/// AuthHeader(
///   title: 'Welcome Back',
///   subtitle: 'Sign in to continue',
///   logoAsset: 'assets/images/logo.png',
/// )
/// ```
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoAsset,
    this.logoWidget,
    this.logoSize = 64.0,
    this.titleStyle,
    this.subtitleStyle,
    this.spacing = 8.0,
    this.logoBottomSpacing = 16.0,
  });

  /// Main heading text, e.g. "Welcome Back".
  final String title;

  /// Supporting text below the title, e.g. "Sign in to continue".
  final String subtitle;

  /// Path to a local image asset for the logo. Ignored if [logoWidget] is set.
  final String? logoAsset;

  /// Custom logo widget. Takes precedence over [logoAsset].
  final Widget? logoWidget;

  /// Size of the logo image (both width and height).
  final double logoSize;

  /// Override for the title text style.
  final TextStyle? titleStyle;

  /// Override for the subtitle text style.
  final TextStyle? subtitleStyle;

  /// Vertical gap between title and subtitle.
  final double spacing;

  /// Vertical gap between the logo and the title.
  final double logoBottomSpacing;

  Widget? _buildLogo() {
    if (logoWidget != null) return logoWidget;
    if (logoAsset != null) {
      return Image.asset(
        logoAsset!,
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final logo = _buildLogo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logo != null) ...[
          logo,
          SizedBox(height: logoBottomSpacing),
        ],
        Text(
          title,
          style: (titleStyle ?? AppTextStyles.heading2).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          subtitle,
          style: (subtitleStyle ?? AppTextStyles.bodyMedium).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
