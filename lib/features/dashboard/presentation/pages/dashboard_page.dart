import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/index.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ── State ─────────────────────────────────────────────────────────────────

  int _selectedCategoryIndex = 0;
  bool _isSetDuration = true; // true = Set Duration, false = Open Timer
  final _activityController = TextEditingController();

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  // ── Category data ──────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _activityCategories = [
    {'label': 'FOCUS', 'icon': Icons.center_focus_strong_outlined},
    {'label': 'LEARNING', 'icon': Icons.menu_book_outlined},
    {'label': 'SOCIAL', 'icon': Icons.people_outline},
    {'label': 'FUN', 'icon': Icons.sports_esports_outlined},
  ];

  static const List<Map<String, dynamic>> _gridCategories = [
    {
      'label': 'Focus',
      'icon': Icons.center_focus_strong_outlined,
      'color': AppColors.primaryDark,
    },
    {
      'label': 'Learning',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFF0EA5E9),
    },
    {
      'label': 'Social Media',
      'icon': Icons.thumb_up_outlined,
      'color': Color(0xFFEC4899),
    },
    {
      'label': 'Entertainment',
      'icon': Icons.movie_outlined,
      'color': Color(0xFFF97316),
    },
  ];

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    DashboardHeader(
                      onNotificationTap: () {
                        // TODO: open notifications
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── NEW ACTIVITY section ──────────────────────────────
                    _buildSectionLabel('NEW ACTIVITY'),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Activity text field
                          AppTextField(
                            hint: 'What are you doing now?',
                            controller: _activityController,
                            prefixIcon: Icons.edit_outlined,
                          ),

                          const SizedBox(height: 16),

                          // Category selector buttons
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                _activityCategories.length,
                                (i) => Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        i < _activityCategories.length - 1
                                            ? 8
                                            : 0,
                                  ),
                                  child: CategoryButton(
                                    label: _activityCategories[i]['label']
                                        as String,
                                    icon: _activityCategories[i]['icon']
                                        as IconData,
                                    isSelected: _selectedCategoryIndex == i,
                                    onTap: () => setState(
                                      () => _selectedCategoryIndex = i,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── DURATION MODE section ─────────────────────────────
                    _buildSectionLabel('DURATION MODE'),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Radio buttons
                          Row(
                            children: [
                              _DurationRadio(
                                label: 'Set Duration',
                                isSelected: _isSetDuration,
                                onTap: () =>
                                    setState(() => _isSetDuration = true),
                              ),
                              const SizedBox(width: 24),
                              _DurationRadio(
                                label: 'Open Timer',
                                isSelected: !_isSetDuration,
                                onTap: () =>
                                    setState(() => _isSetDuration = false),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Duration / infinity row
                          Row(
                            children: [
                              if (_isSetDuration) ...[
                                // Duration input box
                                Container(
                                  width: 110,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '25 MIN',
                                        style:
                                            AppTextStyles.labelLarge.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                // Infinity icon for open timer
                                Container(
                                  width: 110,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primaryDark,
                                        AppColors.primaryLight,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.all_inclusive,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Initiate Flow button ──────────────────────────────
                    PrimaryButton(
                      text: 'INITIATE FLOW',
                      onPressed: () {
                        // TODO: start flow session
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── REVIEW YOUR LAST ACTIVITY ─────────────────────────
                    _buildSectionLabel('REVIEW YOUR LAST ACTIVITY'),
                    const SizedBox(height: 12),
                    ActivityCard(
                      activityName: 'Deep Work API Integration',
                      duration: '420 15s',
                      onProductiveTap: () {
                        // TODO: mark as productive
                      },
                      onConsumptiveTap: () {
                        // TODO: mark as consumptive
                      },
                    ),

                    const SizedBox(height: 28),

                    // ── DAILY PULSE ───────────────────────────────────────
                    _buildSectionLabel('DAILY PULSE'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DailyPulseCard(
                            title: 'Productive',
                            subtitle: 'Focused Mindset',
                            duration: '5h 20m',
                            icon: Icons.bolt,
                            isGradient: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DailyPulseCard(
                            title: 'Drifting',
                            subtitle: 'Passive Consumption',
                            duration: '8h 40m',
                            icon: Icons.water_outlined,
                            isGradient: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Info note
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'More time was lost than used today',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── ACTIVITY CATEGORIES ───────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel('ACTIVITY CATEGORIES'),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.analytics),
                          child: Text(
                            'View Analysis',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: _gridCategories.map((cat) {
                        return CategoryCard(
                          label: cat['label'] as String,
                          icon: cat['icon'] as IconData,
                          iconColor: cat['color'] as Color,
                          onTap: () {
                            // TODO: navigate to category detail
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // ── DAILY REFLECTION quote ────────────────────────────
                    _buildQuoteSection(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Bottom navigation ─────────────────────────────────────────
            DashboardBottomNav(
              currentIndex: 0,
              onTabChanged: (i) {
                if (i == 1) context.go(AppRoutes.analytics);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildQuoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY REFLECTION',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          const Icon(Icons.format_quote, color: Colors.white54, size: 28),
          const SizedBox(height: 6),
          Text(
            'Awareness is the greatest agent for change.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Duration radio helper ───────────────────────────────────────────────────

class _DurationRadio extends StatelessWidget {
  const _DurationRadio({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

