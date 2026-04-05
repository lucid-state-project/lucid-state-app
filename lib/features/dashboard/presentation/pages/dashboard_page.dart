import 'dart:math' as math;

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
  bool _isNavigating = false;
  int _navPreviewIndex = 0;
  bool? _isLastSessionProductive;
  final _activityController = TextEditingController();
  final _durationController = TextEditingController(text: '25');
  final _durationFocusNode = FocusNode();

  Future<void> _navigateWithLoading(String route, int targetIndex) async {
    if (_isNavigating || targetIndex == 0) return;

    setState(() {
      _isNavigating = true;
      _navPreviewIndex = targetIndex;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    context.go(route);
  }

  @override
  void dispose() {
    _activityController.dispose();
    _durationController.dispose();
    _durationFocusNode.dispose();
    super.dispose();
  }

  // ── Category data ──────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _activityCategories = [
    {'label': 'FOCUS', 'icon': Icons.bolt},
    {'label': 'LEARNING', 'icon': Icons.book},
    {'label': 'SOCIAL', 'icon': Icons.people_outline},
    {'label': 'FUN', 'icon': Icons.sports_esports_outlined},
  ];

  static const List<Map<String, dynamic>> _gridCategories = [
    {
      'label': 'Focus',
      'subtitle': 'Deep Work & Flow\nStates',
      'iconAsset': 'assets/icons/dashboard/Icon-9.png',
      'color': AppColors.primary,
    },
    {
      'label': 'Learning',
      'subtitle': 'Courses, Books &\nGrowth',
      'iconAsset': 'assets/icons/dashboard/Icon-10.png',
      'color': AppColors.primaryLight,
    },
    {
      'label': 'Social Media',
      'subtitle': 'Digital Presence\nTracking',
      'iconAsset': 'assets/icons/dashboard/Icon-11.png',
      'color': const Color(0xFF64748B),
    },
    {
      'label': 'Entertainment',
      'subtitle': 'Mindful Recharge\nTime',
      'iconAsset': 'assets/icons/dashboard/Container.png',
      'color': const Color(0xFFF59E0B),
    },
  ];

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: _isNavigating,
              child: Column(
                children: [
                  DashboardHeader(
                    onNotificationTap: () {
                      // TODO: open notifications
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        18,
                        16,
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                      borderRadius: 30,
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── NEW ACTIVITY section ──────────────────────────────
                          _buildSectionLabel('NEW ACTIVITY'),

                          const SizedBox(height: 14),
                          
                          // Activity text field
                          AppTextField(
                            hint: 'What are you doing now?',
                            controller: _activityController,
                            prefixIcon: Icons.edit_outlined,
                          ),

                          const SizedBox(height: 14),

                          // Category selector buttons
                          Row(
                            children: List.generate(
                              _activityCategories.length,
                              (i) => Expanded(
                                child: Padding(
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

                          const SizedBox(height: 16),

                          _buildSectionLabel('DURATION MODE'),
                          const SizedBox(height: 10),

                          // Radio buttons
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _DurationRadio(
                                    label: 'Set Duration',
                                    isSelected: _isSetDuration,
                                    onTap: () {
                                      setState(() => _isSetDuration = true);
                                      _durationFocusNode.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _DurationRadio(
                                    label: 'Open Timer',
                                    isSelected: !_isSetDuration,
                                    onTap: () {
                                      _durationFocusNode.unfocus();
                                      setState(() => _isSetDuration = false);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Duration / infinity row
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() => _isSetDuration = true);
                                    _durationFocusNode.requestFocus();
                                  },
                                  child: Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _isSetDuration
                                          ? AppColors.surfaceVariant
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _isSetDuration
                                            ? AppColors.primary.withOpacity(0.25)
                                            : AppColors.divider,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _durationController,
                                      focusNode: _durationFocusNode,
                                      readOnly: !_isSetDuration,
                                      textAlign: TextAlign.left,
                                      keyboardType: TextInputType.number,
                                      style: AppTextStyles.heading3.copyWith(
                                        color: _isSetDuration
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        suffixText: 'MIN',
                                        suffixStyle: AppTextStyles.labelLarge
                                            .copyWith(
                                          color: _isSetDuration
                                              ? AppColors.textSecondary
                                              : AppColors.textHint,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _durationFocusNode.unfocus();
                                    setState(() => _isSetDuration = false);
                                  },
                                  child: CustomPaint(
                                    painter: _DashedRRectPainter(
                                      color: !_isSetDuration
                                          ? AppColors.primary.withOpacity(0.45)
                                          : AppColors.divider,
                                      radius: 14,
                                      strokeWidth: 1,
                                      dashWidth: 4,
                                      dashGap: 2,
                                    ),
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: !_isSetDuration
                                            ? AppColors.surfaceVariant
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.all_inclusive,
                                          color: _isSetDuration
                                              ? AppColors.textHint
                                              : AppColors.primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Initiate Flow button
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryDark,
                                    AppColors.primaryLight,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryLight.withOpacity(0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    // TODO: start flow session
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Initiate Flow',
                                          style: AppTextStyles.heading3.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                          const SizedBox(height: 16),

                    // ── REVIEW YOUR LAST ACTIVITY ─────────────────────────
                    _buildSectionLabel('REVIEW YOUR LAST ACTIVITY'),
                    const SizedBox(height: 12),
                    ActivityCard(
                      activityName: 'Deep Work API Integration',
                      duration: '420 15s',
                      isProductiveSelected: _isLastSessionProductive,
                      onProductiveTap: () {
                        setState(() {
                          _isLastSessionProductive = true;
                        });
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Marked as productive.'),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                      },
                      onConsumptiveTap: () {
                        setState(() {
                          _isLastSessionProductive = false;
                        });
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Marked as consumptive.'),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
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
                            iconAsset: 'assets/icons/dashboard/Icon-6.png',
                            isGradient: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DailyPulseCard(
                            title: 'Drifting',
                            subtitle: 'Passive Consumption',
                            duration: '8h 40m',
                            iconAsset: 'assets/icons/dashboard/Icon-7.png',
                            isGradient: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Info note
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/dashboard/Icon-8.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'More time was lost than used today',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── ACTIVITY CATEGORIES ───────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel('ACTIVITY CATEGORIES'),
                        GestureDetector(
                          onTap: () => _navigateWithLoading(
                            AppRoutes.analytics,
                            1,
                          ),
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
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.02,
                      children: _gridCategories.map((cat) {
                        return CategoryCard(
                          label: cat['label'] as String,
                          subtitle: cat['subtitle'] as String,
                          iconAsset: cat['iconAsset'] as String,
                          iconBackgroundColor: cat['color'] as Color,
                          onTap: () => _navigateWithLoading(
                            AppRoutes.analytics,
                            1,
                          ),
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
                    currentIndex: _isNavigating ? _navPreviewIndex : 0,
                    onTabChanged: (i) {
                      if (i == 1) {
                        _navigateWithLoading(AppRoutes.analytics, 1);
                      }
                    },
                  ),
                ],
              ),
            ),
            if (_isNavigating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.08),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                ),
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
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 0,
            child: Text(
              '“',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.divider,
                fontSize: 64,
                height: 0.9,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '"Awareness is the greatest\nagent for change."',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading3.copyWith(
                      color: const Color(0xFF3A3D4A),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'DAILY REFLECTION',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: const Color(0xFF9FB0FF),
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap;
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
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

