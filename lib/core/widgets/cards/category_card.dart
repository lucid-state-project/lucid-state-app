import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/cards/app_card.dart';

/// A compact grid card showing an activity category (Focus, Learning, etc.)
/// with an icon and the category name.
///
/// Example:
/// ```dart
/// CategoryCard(
///   label: 'Focus',
///   icon: Icons.center_focus_strong_outlined,
///   onTap: () {},
/// )
/// ```
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.iconAsset,
    this.onTap,
    this.iconBackgroundColor,
  });

  final String label;
  final String subtitle;
  final String iconAsset;
  final VoidCallback? onTap;

  /// Icon background colour. Defaults to a soft gray.
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = iconBackgroundColor ?? AppColors.divider;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(24, 26, 16, 26),
        borderRadius: 24,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(iconAsset, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
