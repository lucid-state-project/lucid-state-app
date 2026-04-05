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
///   iconAsset: 'assets/icons/dashboard/Icon-6.png',
///   isGradient: true,
/// )
/// ```
class DailyPulseCard extends StatelessWidget {
  const DailyPulseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.iconAsset,
    this.isGradient = false,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String iconAsset;

  /// When true, renders a gradient purple background (Productive style).
  final bool isGradient;

  @override
  Widget build(BuildContext context) {
    final titleBadgeColor =
        isGradient ? Colors.white.withOpacity(0.18) : const Color(0xFFE8EDF5);
    final cardTextColor = isGradient ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isGradient
        ? Colors.white.withOpacity(0.88)
        : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      decoration: BoxDecoration(
        gradient: isGradient
            ? const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isGradient ? null : const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(32),
        border: isGradient ? null : Border.all(color: const Color(0xFFD6DEE8)),
        boxShadow: isGradient
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconAsset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: titleBadgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isGradient ? Colors.white : const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            duration.replaceAll(' ', '\n'),
            style: AppTextStyles.heading1.copyWith(
              color: cardTextColor,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            subtitle.toUpperCase().replaceAll(' ', '\n'),
            style: AppTextStyles.labelLarge.copyWith(
              color: subtitleColor,
              height: 1.15,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
