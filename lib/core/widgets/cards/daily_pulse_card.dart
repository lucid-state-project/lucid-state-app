import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A stat card shown in the "DAILY PULSE" section.
///
/// When [isGradient] is true the card uses the brand gradient background
/// (for the "Productive" tile); otherwise it uses a light gray surface (for
/// the "Drifting" tile).
///
/// Example:
/// ```dart
/// DailyPulseCard(
///   title: 'Productive',
///   subtitle: 'Focused Mindset',
///   duration: '5h 20m',
///   icon: Icons.bolt,
///   isGradient: true,
/// )
/// ```
class DailyPulseCard extends StatelessWidget {
  const DailyPulseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    this.isGradient = false,
  });

  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;

  /// When true, renders a gradient purple background (Productive style).
  final bool isGradient;

  @override
  Widget build(BuildContext context) {
    final textColor = isGradient ? Colors.white : AppColors.textPrimary;
    final subtitleColor =
        isGradient ? Colors.white70 : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isGradient
            ? const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isGradient ? null : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isGradient
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isGradient
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isGradient ? Colors.white : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // Duration
          Text(
            duration,
            style: AppTextStyles.heading3.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(color: textColor),
          ),

          const SizedBox(height: 2),

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
