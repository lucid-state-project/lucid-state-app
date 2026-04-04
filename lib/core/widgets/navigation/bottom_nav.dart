import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A custom bottom navigation bar with two tabs: Dashboard and Analytics.
///
/// The active tab is highlighted with a gradient pill; inactive tabs use a
/// muted gray colour.
///
/// [currentIndex] — 0 for Dashboard, 1 for Analytics.
///
/// Example:
/// ```dart
/// DashboardBottomNav(
///   currentIndex: 0,
///   onTabChanged: (i) => context.go(i == 0 ? '/dashboard' : '/analytics'),
/// )
/// ```
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            label: 'DASHBOARD',
            icon: Icons.dashboard_outlined,
            isActive: currentIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _NavItem(
            label: 'ANALYTICS',
            icon: Icons.bar_chart_outlined,
            isActive: currentIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              // Active: gradient pill containing icon + label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Inactive: plain icon + label
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
