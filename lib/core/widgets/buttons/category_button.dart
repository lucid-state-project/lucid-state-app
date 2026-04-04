import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A compact icon + label button used in the "NEW ACTIVITY" section to choose
/// an activity category (FOCUS, LEARNING, SOCIAL, FUN, etc.).
///
/// When [isSelected] is true the button renders with the gradient fill and
/// white text; otherwise it uses a light surface colour.
///
/// Example:
/// ```dart
/// CategoryButton(
///   label: 'FOCUS',
///   icon: Icons.center_focus_strong_outlined,
///   isSelected: true,
///   onTap: () {},
/// )
/// ```
class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
