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
    required this.icon,
    this.onTap,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  /// Icon foreground colour. Defaults to [AppColors.primary].
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        elevation: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
