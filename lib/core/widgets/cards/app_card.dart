import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/core/constants/app_spacing.dart';

/// A generic rounded card container.
///
/// Wraps any [child] widget in a white, rounded, elevated card that can
/// be used for form containers, stat tiles, info panels, and more.
///
/// Example:
/// ```dart
/// AppCard(
///   child: Column(children: [...]),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// Creates a custom card.
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = AppSpacing.radiusLg,
    this.color = AppColors.surface,
    this.elevation = 4.0,
    this.shadowColor,
    this.border,
    this.margin,
    this.width,
    this.height,
  });

  /// The widget placed inside the card.
  final Widget child;

  /// Inner padding around [child]. Defaults to 20 all sides.
  final EdgeInsetsGeometry padding;

  /// Corner radius. Defaults to [AppSpacing.radiusLg].
  final double borderRadius;

  /// Card background color. Defaults to [AppColors.surface].
  final Color color;

  /// Shadow elevation (Material shadow depth). Defaults to 4.0.
  final double elevation;

  /// Shadow color override. Defaults to subtle black shadow.
  final Color? shadowColor;

  /// Optional explicit border.
  final BoxBorder? border;

  /// Outer margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Explicit card width. Omit to let the card size itself.
  final double? width;

  /// Explicit card height. Omit to let the card size itself.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: shadowColor ?? const Color(0x14000000),
                  blurRadius: elevation * 4,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
