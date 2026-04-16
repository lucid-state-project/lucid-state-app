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
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            label: 'DASHBOARD',
            icon: currentIndex == 0 ? Icons.grid_view_rounded : Icons.dashboard_outlined,
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
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isActive ? 156 : 120,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppColors.primaryDark 
                      : AppColors.textPrimary,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.primaryDark 
                        : AppColors.textPrimary,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
