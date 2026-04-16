import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/widgets/cards/app_card.dart';
import 'package:lucid_state_app/core/widgets/navigation/bottom_nav.dart';
import 'package:lucid_state_app/core/services/local_storage_service.dart';
import 'package:lucid_state_app/data/repositories/summary_repository.dart';
import 'package:lucid_state_app/domain/usecases/summary_usecases.dart';
import 'package:lucid_state_app/data/models/activity_models.dart';
import 'package:lucid_state_app/data/repositories/activity_repository.dart';
import 'package:lucid_state_app/domain/usecases/activity_usecases.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isNavigating = false;
  int _navPreviewIndex = 1;
  
  // ── Daily Journey State (dari selected day dari weekly chart)
  late DateTime _selectedDate;
  double _selectedProductiveHours = 0.0;
  double _selectedNonProductiveHours = 0.0;
  int _selectedPointBalance = 0;  // Point balance untuk selected day
  
  // ── Weekly totals untuk progress bar
  double _weeklyTotalProductiveHours = 0.0;
  double _weeklyTotalNonProductiveHours = 0.0;

  // ── Activity Sessions (untuk Timeline)
  List<ActivitySession> _activitySessions = [];
  bool _isLoadingActivities = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected date ke hari ini
    _selectedDate = DateTime.now();
  }

  /// 📅 Format DateTime ke YYYY-MM-DD format untuk API
  /// 
  /// Contoh: DateTime(2026, 4, 10) → "2026-04-10"
  String _formatDateToApi(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

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

  /// 📢 Update selected day dari weekly chart
  void _updateSelectedDay(
    DateTime date,
    double productiveHours,
    double nonProductiveHours,
    {required double weeklyProductiveTotal, required double weeklyNonProductiveTotal}
  ) {
    setState(() {
      _selectedDate = date;
      _selectedProductiveHours = productiveHours;
      _selectedNonProductiveHours = nonProductiveHours;
      _weeklyTotalProductiveHours = weeklyProductiveTotal;
      _weeklyTotalNonProductiveHours = weeklyNonProductiveTotal;
    });

    // 📋 Load activity sessions untuk selected date
    // Point balance akan dihitung dari sum points setelah sessions dimuat
    _loadActivitySessions(date);
  }

  /// 📋 Load activity sessions dari API untuk date tertentu
  Future<void> _loadActivitySessions(DateTime date) async {
    setState(() {
      _isLoadingActivities = true;
    });

    try {
      print('📋 Loading activity sessions for date: $date');

      // 🔍 Get userId dari local storage
      final localStorage = LocalStorageService();
      final userId = localStorage.getGuestUserId();

      if (userId == null) {
        print('❌ User ID not found');
        return;
      }

      // 📅 Format date ke YYYY-MM-DD
      final dateStr = _formatDateToApi(date);
      print('📅 Formatted date: $dateStr');

      // 📨 Call API
      final activityRepository = ActivityRepositoryImpl();
      final useCase = GetActivitySessionsUseCase(activityRepository);
      final response = await useCase.call(
        GetActivitySessionsParams(
          userId: userId,
          date: dateStr,
        ),
      );

      if (!mounted) return;

      print('✅ Loaded ${response.sessions.length} activity sessions');
      
      // 🔍 Debug: Print FIRST session
      if (response.sessions.isNotEmpty) {
        final s = response.sessions[0];
        print('   ✅ FIRST SESSION ON PAGE:');
        print('      - title: "${s.activityName}"');
        print('      - category: "${s.categoryName}"');
        print('      - points: ${s.points}');
        print('      - isProductive: ${s.isProductive}');
      }

      // 📊 Calculate point balance dari sum semua session points
      int totalPoints = 0;
      for (final session in response.sessions) {
        if (session.points != null) {
          totalPoints += session.points!;
        }
      }
      print('📊 Calculated point balance from sessions: $totalPoints');

      setState(() {
        _activitySessions = response.sessions;
        _selectedPointBalance = totalPoints;
        _isLoadingActivities = false;
      });
    } catch (e) {
      print('❌ Error loading activity sessions: $e');
      if (mounted) {
        setState(() {
          _isLoadingActivities = false;
          _activitySessions = [];
          _selectedPointBalance = 0;
        });
      }
    }
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
                        children: [
                          _WeeklyAnalyticsSection(
                            onDaySelected: _updateSelectedDay,
                          ),
                          const SizedBox(height: 24),
                          _DailyJourneySection(
                            selectedDate: _selectedDate,
                            productiveHours: _selectedProductiveHours,
                            nonProductiveHours: _selectedNonProductiveHours,
                            pointBalance: _selectedPointBalance,
                            weeklyTotalProductive: _weeklyTotalProductiveHours,
                            weeklyTotalNonProductive: _weeklyTotalNonProductiveHours,
                          ),
                          const SizedBox(height: 24),
                          _TimelineSection(
                            sessions: _activitySessions,
                            isLoading: _isLoadingActivities,
                          ),
                          const SizedBox(height: 20),
                          _ReviewCompleteSection(
                            productiveHours: _selectedProductiveHours,
                            nonProductiveHours: _selectedNonProductiveHours,
                          ),
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
          GestureDetector(
            onTap: () => context.push(AppRoutes.configuration),
            child: Image.asset(
              'assets/icons/Analytic/Icon-4.png',
              width: 22,
              height: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyAnalyticsSection extends StatefulWidget {
  final Function(DateTime, double, double, {required double weeklyProductiveTotal, required double weeklyNonProductiveTotal})? onDaySelected;
  
  const _WeeklyAnalyticsSection({this.onDaySelected});

  @override
  State<_WeeklyAnalyticsSection> createState() => _WeeklyAnalyticsSectionState();
}

class _WeeklyAnalyticsSectionState extends State<_WeeklyAnalyticsSection> {
  static const List<String> _monthShort = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  late DateTime _weekStart;
  int _selectedDayIndex = DateTime.now().weekday - 1;

  // ── API & Use Cases
  late final GetWeeklySummaryUseCase _getWeeklySummaryUseCase;
  
  // ── Loading State
  bool _isLoading = false;
  
  // ── Weekly Data dari API
  // Initialized dengan empty arrays, di-fill ketika API response
  late List<double> _productiveHours = [];
  late List<double> _nonProductiveHours = [];
  
  // ── Dynamic Y-Axis Scale
  // Max scale untuk Y-axis, calculated berdasarkan data
  // Dimulai dari 4h (minimum), bisa naik ke 8h, 12h, etc sesuai data
  double _maxYAxisScale = 4.0;  // Default minimum

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - 1),
    );
    
    // ── Initialize use case
    final summaryRepository = SummaryRepositoryImpl();
    _getWeeklySummaryUseCase = GetWeeklySummaryUseCase(summaryRepository);
    
    // ── 🚀 Load weekly data saat page load
    _loadWeeklySummary();
  }

  /// 📊 Load weekly summary data dari API
  /// 
  /// Flow:
  /// 1. Mark loading state (true)
  /// 2. Retrieve userId dari local storage
  /// 3. Format week start date ke YYYY-MM-DD
  /// 4. Call GetWeeklySummaryUseCase dengan params
  /// 5. API returns array of 7 days
  /// 6. Convert detik → hours untuk productive & non-productive
  /// 7. Build arrays untuk chart display
  /// 8. Update UI via setState
  /// 9. Handle errors & reset loading state
  Future<void> _loadWeeklySummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📊 Loading weekly summary for week starting: $_weekStart');
      
      // 🔍 Get userId dari local storage (saved guest UUID)
      final localStorage = LocalStorageService();
      final userId = localStorage.getGuestUserId();
      
      if (userId == null) {
        print('❌ User ID not found in local storage');
        _showErrorMessage('User not authenticated');
        return;
      }
      
      print('👤 Using userId: $userId');

      // 📅 Format date ke YYYY-MM-DD
      final dateStr = _formatDateToApi(_weekStart);
      print('📅 Requesting data for date: $dateStr');

      // 📨 Call API
      final weeklySummary = await _getWeeklySummaryUseCase.call(
        GetWeeklySummaryParams(
          userId: userId,
          date: dateStr,
        ),
      );

      if (!mounted) return;

      print('✅ Received weekly summary with ${weeklySummary.days.length} days');

      // 🔄 Convert dari seconds → hours untuk chart
      final productiveHours = <double>[];
      final nonProductiveHours = <double>[];

      for (final day in weeklySummary.days) {
        print('   📆 ${day.date}: productive=${day.productiveHours}h, non-productive=${day.nonProductiveHours}h');
        productiveHours.add(day.productiveHours);
        nonProductiveHours.add(day.nonProductiveHours);
      }

      // 📊 Calculate dynamic max scale untuk Y-axis
      // Berdasarkan nilai maksimal dari semua data
      final maxValue = _calculateDynamicMaxScale(productiveHours, nonProductiveHours);
      print('📈 Dynamic max Y-axis scale: ${maxValue}h');

      // 📊 Update UI dengan data dari API
      setState(() {
        _productiveHours = productiveHours;
        _nonProductiveHours = nonProductiveHours;
        _maxYAxisScale = maxValue;
        _isLoading = false;
      });

      print('✅ UI updated with weekly data');
      
      // 📢 Auto-select today's data untuk Daily Journey
      // Trigger callback ke parent dengan data hari yang dipilih
      if (productiveHours.isNotEmpty && nonProductiveHours.isNotEmpty) {
        final selectedDate = _getSelectedDate();
        final productive = productiveHours[_selectedDayIndex];
        final nonProductive = nonProductiveHours[_selectedDayIndex];
        
        // 📊 Calculate weekly totals
        final weeklyProductiveTotal = productiveHours.reduce((a, b) => a + b);
        final weeklyNonProductiveTotal = nonProductiveHours.reduce((a, b) => a + b);
        
        print('📢 Auto-selecting day: ${selectedDate.toIso8601String()}');
        print('   └─ Productive: ${productive}h, Non-productive: ${nonProductive}h');
        print('   └─ Weekly totals - Productive: ${weeklyProductiveTotal.toStringAsFixed(2)}h, Non-productive: ${weeklyNonProductiveTotal.toStringAsFixed(2)}h');
        
        widget.onDaySelected?.call(
          selectedDate,
          productive,
          nonProductive,
          weeklyProductiveTotal: weeklyProductiveTotal,
          weeklyNonProductiveTotal: weeklyNonProductiveTotal,
        );
      }
    } catch (e) {
      print('❌ Error loading weekly summary: $e');
      if (mounted) {
        _showErrorMessage('Failed to load weekly data');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 📈 Calculate dynamic max Y-axis scale berdasarkan data
  /// 
  /// Logic:
  /// 1. Hitung total kombinasi productive + non-productive untuk setiap hari
  /// 2. Cari nilai maksimal dari semua hari
  /// 3. Tentukan scale yang sesuai (granular untuk user baru dengan data sedikit):
  ///    - Jika max <= 0.5h → gunakan 0.5h (30 menitan, untuk user sangat baru)
  ///    - Jika max <= 1h → gunakan 1h
  ///    - Jika max <= 2h → gunakan 2h
  ///    - Jika max <= 4h → gunakan 4h
  ///    - Jika max <= 8h → gunakan 8h
  ///    - Jika max <= 12h → gunakan 12h
  ///    - Jika max > 12h → gunakan 16h (bisa lanjut naik)
  /// 4. Return scale untuk UI rendering
  /// 
  /// Contoh:
  /// - Data: productive=[0.2, 0.3], non-productive=[0.1, 0.2]
  ///   Total: [0.3, 0.5] → max=0.5 → return 0.5h (30 menitan)
  /// - Data: productive=[0.5, 0.8], non-productive=[0.2, 0.3]
  ///   Total: [0.7, 1.1] → max=1.1 → return 2h
  /// - Data: productive=[2, 3], non-productive=[1, 2]
  ///   Total: [3, 5] → max=5 → return 8h
  double _calculateDynamicMaxScale(
    List<double> productiveHours,
    List<double> nonProductiveHours,
  ) {
    // 🔍 Find maximum value
    double maxValue = 0.0;
    for (int i = 0; i < productiveHours.length; i++) {
      final total = productiveHours[i] + nonProductiveHours[i];
      maxValue = maxValue < total ? total : maxValue;
    }

    print('      └─ Max total hours: ${maxValue.toStringAsFixed(2)}h');

    // 📏 Determine appropriate scale dengan 0.5h increments
    // Dapatkan scale dengan rounding ke atas ke 0.5h terdekat
    double scale = 0.5; // Minimum scale adalah 0.5h (30 menitan)
    while (scale < maxValue) {
      scale += 0.5;
    }
    
    // Cap scale maksimal di 16h untuk performance
    if (scale > 16.0) {
      scale = 16.0;
    }
    
    print('      └─ Max value ${maxValue.toStringAsFixed(2)}h → rounded up scale: ${scale.toStringAsFixed(1)}h');
    return scale;
  }

  /// 📅 Format DateTime ke YYYY-MM-DD format untuk API
  /// 
  /// Contoh: DateTime(2026, 4, 10) → "2026-04-10"
  String _formatDateToApi(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 🔄 Reload data ketika user navigate ke minggu lain
  /// 
  /// Called when:
  /// - User klik arrow untuk previous week
  /// - User klik arrow untuk next week
  Future<void> _handleWeekChange() async {
    print('🔄 Week changed to: $_weekStart');
    await _loadWeeklySummary();
  }

  /// ⚠️ Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 🏷️ Format hour value untuk Y-axis label (tampilkan dengan decimal jika perlu, TANPA rounding)
  /// 
  /// Contoh:
  /// - 0.5 → "0.5h"
  /// - 0.25 → "0.25h" (NOT rounded to "0.3h"!)
  /// - 1.0 → "1h"
  /// - 1.5 → "1.5h"
  /// - 2.0 → "2h"
  String _formatHourLabel(double hours) {
    // Jika hours adalah nilai bulat (1, 2, 3, dll) → tampilkan tanpa decimal
    if (hours == hours.toInt()) {
      return '${hours.toInt()}h';
    }
    // Jika ada decimal → gunakan toStringAsFixed(2) untuk precision
    // Terus trim trailing zero (1.50 → 1.5)
    String formatted = hours.toStringAsFixed(2);
    if (formatted.endsWith('0') && formatted.contains('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return '${formatted}h';
  }

  String _weekRangeLabel() {
    final end = _weekStart.add(const Duration(days: 6));
    final startMonth = _monthShort[_weekStart.month - 1];
    final endMonth = _monthShort[end.month - 1];

    if (_weekStart.month == end.month) {
      return '$startMonth ${_weekStart.day} - ${end.day}, ${end.year}';
    }

    return '$startMonth ${_weekStart.day} - $endMonth ${end.day}, ${end.year}';
  }

  /// 📅 Get selected day's date
  DateTime _getSelectedDate() {
    return _weekStart.add(Duration(days: _selectedDayIndex));
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ NOTE: Data sekarang dari API (_productiveHours, _nonProductiveHours)
    // tidak lagi hardcoded di sini

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
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 210),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _weekStart = _weekStart.subtract(const Duration(days: 7));
                          });
                          // 🔄 Reload data untuk minggu yang baru
                          _handleWeekChange();
                        },
                        child: const Icon(
                          Icons.chevron_left,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _weekRangeLabel(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _weekStart = _weekStart.add(const Duration(days: 7));
                          });
                          // 🔄 Reload data untuk minggu yang baru
                          _handleWeekChange();
                        },
                        child: const Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
              // 📊 LOADING atau CHART
              _isLoading
                  ? SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 26,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 📈 Dynamic Y-axis labels berdasarkan _maxYAxisScale
                                      _YAxisLabel(_formatHourLabel(_maxYAxisScale)),
                                      _YAxisLabel(_formatHourLabel(_maxYAxisScale / 2)),
                                      const _YAxisLabel('0h'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(7, (i) {
                                // 📋 Get data dari API (fallback ke 0 jika empty)
                                final productive = i < _productiveHours.length
                                    ? _productiveHours[i]
                                    : 0.0;
                                final isSelected = i == _selectedDayIndex;
                                return Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _selectedDayIndex = i;
                                      });
                                      // 📢 Notify parent tentang day selection
                                      final selectedDate = _getSelectedDate();
                                      final productive = i < _productiveHours.length
                                          ? _productiveHours[i]
                                          : 0.0;
                                      final nonProductive = i < _nonProductiveHours.length
                                          ? _nonProductiveHours[i]
                                          : 0.0;
                                      
                                      // 📊 Calculate weekly totals
                                      final weeklyProductiveTotal = _productiveHours.reduce((a, b) => a + b);
                                      final weeklyNonProductiveTotal = _nonProductiveHours.reduce((a, b) => a + b);
                                      
                                      widget.onDaySelected?.call(
                                        selectedDate,
                                        productive,
                                        nonProductive,
                                        weeklyProductiveTotal: weeklyProductiveTotal,
                                        weeklyNonProductiveTotal: weeklyNonProductiveTotal,
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment:
                                                Alignment.bottomCenter,
                                            child: _StackBar(
                                              productive: productive,
                                              passive: i <
                                                      _nonProductiveHours.length
                                                  ? _nonProductiveHours[i]
                                                  : 0.0,
                                              isSelected: isSelected,
                                              maxScale: _maxYAxisScale,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                                              [i],
                                          style:
                                              AppTextStyles.labelMedium.copyWith(
                                            color: isSelected
                                                ? AppColors.primaryDark
                                                : AppColors.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
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
    required this.maxScale,
  });

  final double productive;
  final double passive;
  final bool isSelected;
  
  /// 📈 Maximum scale untuk bar height calculation
  /// Dinamis berdasarkan data (4h, 8h, 12h, 16h, etc)
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    // 📏 Use dynamic maxScale instead of hardcoded 8.0
    const h = 138.0;
    final productiveH = (productive / maxScale) * h;
    final passiveH = (passive / maxScale) * h;
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

class _YAxisLabel extends StatelessWidget {
  const _YAxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 🏷️ Format time hours into readable label (minutes for < 1h, hours+minutes for >= 1h)
/// Contoh: 0.296h → "18m", 1.5h → "1h 30m", 2.0h → "2h"
String _formatTimeLabel(double hours) {
  if (hours == 0) return '0m';
  
  final totalMinutes = (hours * 60).round();
  final wholeHours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  
  if (wholeHours == 0) {
    return '${minutes}m';
  } else if (minutes == 0) {
    return '${wholeHours}h';
  } else {
    return '${wholeHours}h ${minutes}m';
  }
}

class _DailyJourneySection extends StatelessWidget {
  final DateTime selectedDate;
  final double productiveHours;
  final double nonProductiveHours;
  final int pointBalance;
  final double weeklyTotalProductive;
  final double weeklyTotalNonProductive;
  
  const _DailyJourneySection({
    required this.selectedDate,
    required this.productiveHours,
    required this.nonProductiveHours,
    required this.pointBalance,
    required this.weeklyTotalProductive,
    required this.weeklyTotalNonProductive,
  });

  @override
  Widget build(BuildContext context) {
    // 🏷️ Format selected date label
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final dayName = dayNames[selectedDate.weekday - 1];
    final monthName = monthNames[selectedDate.month - 1];
    final displayText = isToday ? 'Today' : dayName;
    final dateLabel = '$displayText, $monthName ${selectedDate.day}';

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
              dateLabel,
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
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
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
              const SizedBox(height: 14),
              Text(
                '+$pointBalance',
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        // 📊 Calculate progress percentage for PRODUCTIVE based on SELECTED DAY ratio
                        // Display selected day value dengan format "18m", "1h 30m", etc
                        final selectedDayTotal = productiveHours + nonProductiveHours;
                        final productivePercent = selectedDayTotal > 0 
                            ? productiveHours / selectedDayTotal 
                            : 0.0;
                        
                        return _MiniBalanceCard(
                          title: 'PRODUCTIVE',
                          value: _formatTimeLabel(productiveHours),
                          progressPercentage: productivePercent,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        // 📊 Calculate progress percentage for DRIFTING based on SELECTED DAY ratio
                        // Display selected day value dengan format "18m", "1h 30m", etc
                        final selectedDayTotal = productiveHours + nonProductiveHours;
                        final driftingPercent = selectedDayTotal > 0 
                            ? nonProductiveHours / selectedDayTotal 
                            : 0.0;
                        
                        return _MiniBalanceCard(
                          title: 'DRIFTING',
                          value: _formatTimeLabel(nonProductiveHours),
                          progressPercentage: driftingPercent,
                        );
                      },
                    ),
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
  const _MiniBalanceCard({
    required this.title,
    required this.value,
    required this.progressPercentage,
  });

  final String title;
  final String value;
  final double progressPercentage; // 0.0 to 1.0

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercentage.clamp(0.0, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final List<ActivitySession> sessions;
  final bool isLoading;

  const _TimelineSection({
    required this.sessions,
    required this.isLoading,
  });

  /// 🎨 Map category name ke icon yang sesuai
  /// 
  /// Logic:
  /// - Setiap category punya icon yang berbeda
  /// - Jika category tidak dikenali, gunakan Icon-1 sebagai default
  /// 
  /// Contoh mapping (adjust sesuai dengan kategori real):
  /// - "Work" → Icon-1.png
  /// - "Learning" → Icon-2.png
  /// - "Entertainment" → Icon-3.png
  /// - "Social" → Icon-4.png
  /// - "Exercise" → Icon-5.png
  /// - "Reading" → Icon-6.png
  /// - Default → Icon-1.png
  String _getIconForCategory(String category) {
    final categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('work') || categoryLower.contains('code')) {
      return 'assets/icons/Analytic/Icon-1.png';
    } else if (categoryLower.contains('learn') || categoryLower.contains('study')) {
      return 'assets/icons/Analytic/Icon-2.png';
    } else if (categoryLower.contains('entertain') || categoryLower.contains('game') || categoryLower.contains('watch')) {
      return 'assets/icons/Analytic/Icon-3.png';
    } else if (categoryLower.contains('social') || categoryLower.contains('chat') || categoryLower.contains('message')) {
      return 'assets/icons/Analytic/Icon-4.png';
    } else if (categoryLower.contains('exercise') || categoryLower.contains('sport') || categoryLower.contains('fitness')) {
      return 'assets/icons/Analytic/Icon-5.png';
    } else if (categoryLower.contains('read') || categoryLower.contains('book')) {
      return 'assets/icons/Analytic/Icon-6.png';
    } else {
      // Default icon untuk category yang tidak dikenali
      return 'assets/icons/Analytic/Icon-1.png';
    }
  }

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
        const SizedBox(height: 24),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          )
        else if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No activities tracked today',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...sessions.map((session) {
            // 🎨 Determine color berdasarkan isProductive
            final scoreColor = session.isProductive == true
                ? AppColors.primaryDark
                : (session.isProductive == false ? const Color(0xFFDC2626) : AppColors.primaryLight);

            // 📊 Format score dengan +/- prefix
            // Jika points positive: +10
            // Jika points negative: -5 (jangan double minus)
            final scoreText = session.points != null
                ? (session.points! >= 0 ? '+${session.points}' : '${session.points}')
                : (session.isProductive == null ? '??' : '0');

            // 🎨 Map category ke icon yang berbeda
            final iconAsset = _getIconForCategory(session.categoryName);

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _TimelineItem(
                iconAsset: iconAsset,
                title: session.activityName,
                subtitle: '${session.categoryName} • ${session.formattedStartTime}',
                score: scoreText,
                scoreColor: scoreColor,
                duration: session.formattedDuration,
              ),
            );
          }).toList(),
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
  final double productiveHours;
  final double nonProductiveHours;
  
  const _ReviewCompleteSection({
    required this.productiveHours,
    required this.nonProductiveHours,
  });

  @override
  Widget build(BuildContext context) {
    // 📊 Calculate total tracked hours
    final totalHours = productiveHours + nonProductiveHours;
    final totalMinutes = (totalHours * 60).round();
    final wholeHours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    // 🏷️ Format total time
    final timeDisplay = wholeHours > 0 
        ? (minutes > 0 ? '$wholeHours h $minutes m' : '$wholeHours h')
        : '$minutes m';
    
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
            "You've tracked $timeDisplay of your cognitive energy\ntoday.",
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
