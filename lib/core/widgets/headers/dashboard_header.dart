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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 14, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.bubble_chart_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            'Lucid Mindset',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onNotificationTap,
            splashRadius: 20,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF6C7A91),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
