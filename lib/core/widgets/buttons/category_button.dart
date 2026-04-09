import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/constants/app_spacing.dart';

/// A compact icon + label button used in the "NEW ACTIVITY" section to choose
/// an activity category (FOCUS, LEARNING, SOCIAL, FUN, etc.).
///
/// When [isSelected] is true the button renders with the gradient fill and
/// white text; otherwise it uses a light surface colour.
///
/// Supports both icon (IconData) and image URL (String) for the category icon.
/// If [imageUrl] is provided, it takes precedence over [icon].
///
/// Example:
/// ```dart
/// CategoryButton(
///   label: 'FOCUS',
///   icon: Icons.center_focus_strong_outlined,
///   isSelected: true,
///   onTap: () {},
/// )
/// 
/// // Or with image URL:
/// CategoryButton(
///   label: 'Focus',
///   imageUrl: 'https://example.com/focus.png',
///   isSelected: false,
///   onTap: () {},
/// )
/// ```
class CategoryButton extends StatelessWidget {
  const CategoryButton({
    super.key,
    required this.label,
    this.icon,
    this.imageUrl,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 84,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs + 2,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8E6F5)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF15157D).withOpacity(0.15)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Circle - More prominent design
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFD4D0E8)
                    : const Color(0xFFE8E8E8),
              ),
              child: imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return Icon(
                            icon ?? Icons.category,
                            size: 20,
                            color: isSelected
                                ? const Color(0xFF15157D)
                                : AppColors.textSecondary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      icon ?? Icons.category,
                      size: 20,
                      color: isSelected
                          ? const Color(0xFF15157D)
                          : AppColors.textSecondary,
                    ),
            ),
            SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? const Color(0xFF15157D)
                      : AppColors.textSecondary,
                  letterSpacing: 0.3,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
