import 'package:flutter/material.dart';
import 'package:lucid_state_app/core/widgets/buttons/secondary_button.dart';

/// Deprecated: Use [SecondaryButton] instead.
///
/// [SocialButton] is now an alias for [SecondaryButton] with
/// social-oriented defaults. This class is maintained for backward
/// compatibility and will be removed in a future version.
@Deprecated('Use SecondaryButton instead. This class will be removed in v2.0.0')
class SocialButton extends StatelessWidget {
  /// Creates a social button. Use [SecondaryButton] instead.
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
  /// Use [SecondaryButton.iconAsset] parameter instead.
  final String? iconAsset;

  /// Custom icon widget. Takes precedence over [iconAsset].
  /// Use [SecondaryButton.icon] parameter instead.
  final Widget? iconWidget;

  /// Width of the button.
  final double width;

  /// Height of the button.
  final double height;

  /// Corner radius.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      text: text,
      onPressed: onPressed,
      icon: iconWidget,
      iconAsset: iconAsset,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}
