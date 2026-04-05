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
    this.isProductiveSelected,
    this.onProductiveTap,
    this.onConsumptiveTap,
  });

  final String activityName;
  final String duration;
  final bool? isProductiveSelected;
  final VoidCallback? onProductiveTap;
  final VoidCallback? onConsumptiveTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityName,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: $duration',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/icons/dashboard/Icon-3.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            'Was this session productive?',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              // Productive button
              Expanded(
                child: _FeedbackButton(
                  label: 'Productive',
                  iconAsset: 'assets/icons/dashboard/Icon-4.png',
                  isPositive: true,
                  isSelected: isProductiveSelected == true,
                  onTap: onProductiveTap,
                ),
              ),
              const SizedBox(width: 10),
              // Consumptive button
              Expanded(
                child: _FeedbackButton(
                  label: 'Consumptive',
                  iconAsset: 'assets/icons/dashboard/Icon-5.png',
                  isPositive: false,
                  isSelected: isProductiveSelected == false,
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
    required this.iconAsset,
    required this.isPositive,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool isPositive;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.textSecondary;
    final selectedBackground = isPositive
      ? AppColors.success.withOpacity(0.18)
      : AppColors.textSecondary.withOpacity(0.12);
    final unselectedBackground = isPositive
      ? AppColors.success.withOpacity(0.12)
      : AppColors.surfaceVariant;
    final selectedBorder = isPositive
      ? AppColors.success.withOpacity(0.55)
      : AppColors.textSecondary.withOpacity(0.45);
    final unselectedBorder = isPositive
      ? AppColors.success.withOpacity(0.2)
      : AppColors.divider;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : unselectedBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? selectedBorder : unselectedBorder,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconAsset,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
