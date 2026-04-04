import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/cards/app_card.dart';

/// A card that shows a summary of the user's last tracked activity and asks
/// whether it was productive or consumptive.
///
/// Example:
/// ```dart
/// ActivityCard(
///   activityName: 'Deep Work API Integration',
///   duration: '420 15s',
///   onProductiveTap: () {},
///   onConsumptiveTap: () {},
/// )
/// ```
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activityName,
    required this.duration,
    this.onProductiveTap,
    this.onConsumptiveTap,
  });

  final String activityName;
  final String duration;
  final VoidCallback? onProductiveTap;
  final VoidCallback? onConsumptiveTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Activity row ──────────────────────────────────────────────
          Row(
            children: [
              // Icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityName,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(color: AppColors.divider, height: 1),

          const SizedBox(height: 16),

          // ── Productivity question ─────────────────────────────────────
          Text(
            'Was this session productive?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Productive button
              Expanded(
                child: _FeedbackButton(
                  label: 'Productive',
                  icon: Icons.thumb_up_outlined,
                  isPositive: true,
                  onTap: onProductiveTap,
                ),
              ),
              const SizedBox(width: 10),
              // Consumptive button
              Expanded(
                child: _FeedbackButton(
                  label: 'Consumptive',
                  icon: Icons.thumb_down_outlined,
                  isPositive: false,
                  onTap: onConsumptiveTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Internal helper button for the productive / consumptive feedback row.
class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.label,
    required this.icon,
    required this.isPositive,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPositive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
