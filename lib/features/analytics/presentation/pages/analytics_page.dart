import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/cards/app_card.dart';
import 'package:lucid_state_app/core/widgets/navigation/bottom_nav.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isNavigating = false;
  int _navPreviewIndex = 1;

  Future<void> _navigateWithLoading(String route, int targetIndex) async {
    if (_isNavigating || targetIndex == 1) return;

    setState(() {
      _isNavigating = true;
      _navPreviewIndex = targetIndex;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    context.go(route);
  }

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
                  const _AnalyticsHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _WeeklyAnalyticsSection(),
                          SizedBox(height: 24),
                          _DailyJourneySection(),
                          SizedBox(height: 24),
                          _TimelineSection(),
                          SizedBox(height: 20),
                          _ReviewCompleteSection(),
                        ],
                      ),
                    ),
                  ),
                  DashboardBottomNav(
                    currentIndex: _isNavigating ? _navPreviewIndex : 1,
                    onTabChanged: (i) {
                      if (i == 0) {
                        _navigateWithLoading(AppRoutes.dashboard, 0);
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
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFF334155), size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            'LUCID',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primaryDark,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Image.asset(
            'assets/icons/Analytic/Icon-4.png',
            width: 22,
            height: 22,
          ),
        ],
      ),
    );
  }
}

class _WeeklyAnalyticsSection extends StatelessWidget {
  const _WeeklyAnalyticsSection();

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const productive = [3.6, 3.0, 4.6, 3.2, 4.0, 2.0, 1.8];
    const passive = [2.0, 2.8, 1.5, 3.3, 0.9, 4.6, 5.4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Weekly Analytics',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chevron_left, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    'MAY 12 - 18',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          borderRadius: 28,
          elevation: 1,
          child: Column(
            children: [
              SizedBox(
                height: 172,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(days.length, (i) {
                    final isSelected = i == 6;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: _StackBar(
                                productive: productive[i],
                                passive: passive[i],
                                isSelected: isSelected,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            days[i],
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: AppColors.primaryDark, label: 'PRODUCTIVE'),
                  const SizedBox(width: 20),
                  _LegendDot(color: AppColors.primaryLight, label: 'PASSIVE'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StackBar extends StatelessWidget {
  const _StackBar({
    required this.productive,
    required this.passive,
    required this.isSelected,
  });

  final double productive;
  final double passive;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const max = 8.0;
    const h = 126.0;
    final productiveH = (productive / max) * h;
    final passiveH = (passive / max) * h;
    final topGapH = h - productiveH - passiveH;

    Widget bar = Container(
      width: 14,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFFEBEDF2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Column(
          children: [
            SizedBox(height: topGapH.clamp(0, h)),
            Container(height: productiveH.clamp(0, h), color: AppColors.primaryDark),
            Container(height: passiveH.clamp(0, h), color: AppColors.primaryLight),
          ],
        ),
      ),
    );

    if (!isSelected) return bar;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primaryDark, width: 2),
      ),
      child: bar,
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _DailyJourneySection extends StatelessWidget {
  const _DailyJourneySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Journey',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              'Today, Oct 24',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Image.asset('assets/icons/Analytic/Icon-7.png', width: 14, height: 14),
                  const SizedBox(width: 6),
                  Text(
                    'History',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.34),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'POINT BALANCE',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white.withOpacity(0.75),
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'ASCENDING',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '+450',
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: const [
                  Expanded(
                    child: _MiniBalanceCard(title: 'PRODUCTIVE', value: '6h 12m'),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _MiniBalanceCard(title: 'DRIFTING', value: '1h 45m'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniBalanceCard extends StatelessWidget {
  const _MiniBalanceCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Timeline',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              'SORT BY: TIME',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _TimelineItem(
          iconAsset: 'assets/icons/Analytic/Icon.png',
          title: 'Deep Study',
          subtitle: 'Learning Rust Systems • 10:30 AM',
          score: '+120',
          scoreColor: AppColors.primaryDark,
          duration: '45 MINS',
        ),
        const SizedBox(height: 10),
        const _TimelineItem(
          iconAsset: 'assets/icons/Analytic/Icon-1.png',
          title: 'Instagram Scrolling',
          subtitle: 'Passive Entertainment • 11:15 AM',
          score: '-45',
          scoreColor: Color(0xFFDC2626),
          duration: '25 MINS',
        ),
        const SizedBox(height: 10),
        const _TimelineItem(
          iconAsset: 'assets/icons/Analytic/Icon-2.png',
          title: 'Morning Meditation',
          subtitle: 'Mindfulness Practice • 08:00 AM',
          score: '+200',
          scoreColor: AppColors.primaryLight,
          duration: '20 MINS',
        ),
        const SizedBox(height: 10),
        const _TimelineItem(
          iconAsset: 'assets/icons/Analytic/Icon-3.png',
          title: 'YouTube Spiral',
          subtitle: 'Tech News Binge • 01:20 PM',
          score: '-80',
          scoreColor: Color(0xFFDC2626),
          duration: '55 MINS',
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.scoreColor,
    required this.duration,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final String score;
  final Color scoreColor;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      borderRadius: 24,
      elevation: 1,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: AppTextStyles.heading3.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                duration,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCompleteSection extends StatelessWidget {
  const _ReviewCompleteSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Text(
            'Review Complete?',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You've tracked 8 hours of your cognitive energy\ntoday.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Finalize Daily Log',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
