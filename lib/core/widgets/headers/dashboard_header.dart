import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// Top header for the Dashboard screen.
///
/// Displays the "Lucid Mindset" brand name with a gradient accent bar and a
/// notification bell icon on the trailing edge.
///
/// Example:
/// ```dart
/// DashboardHeader(onNotificationTap: () { /* handle */ })
/// ```
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, this.onNotificationTap});

  /// Callback fired when the notification bell is tapped.
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Brand ────────────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lucid Mindset',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),

        const Spacer(),

        // ── Notification bell ─────────────────────────────────────────────
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
