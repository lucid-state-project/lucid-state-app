import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucid_state_app/app/router/routes.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';
import 'package:lucid_state_app/core/services/timer_service.dart';
import 'package:lucid_state_app/core/services/session_service.dart';
import 'package:lucid_state_app/core/services/local_storage_service.dart';
import 'package:lucid_state_app/core/widgets/index.dart';
import 'package:lucid_state_app/core/extensions/string_extensions.dart';
import 'package:lucid_state_app/data/repositories/session_repository.dart';
import 'package:lucid_state_app/data/repositories/summary_repository.dart';
import 'package:lucid_state_app/data/repositories/category_activity_repository.dart';
import 'package:lucid_state_app/domain/usecases/base_usecase.dart';
import 'package:lucid_state_app/domain/usecases/session_usecases.dart';
import 'package:lucid_state_app/domain/usecases/summary_usecases.dart';
import 'package:lucid_state_app/domain/usecases/category_activity_usecases.dart';
import 'package:lucid_state_app/data/models/category_activity_models.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────

  int _selectedCategoryIndex = 0;
  bool _isSetDuration = true; // true = Set Duration, false = Open Timer
  bool _isNavigating = false;
  int _navPreviewIndex = 0;
  bool? _isLastSessionProductive;
  
  // ── Animation state
  late AnimationController _cardSlideController;
  late Animation<Offset> _slideAnimation;
  bool _shouldAnimateCardExit = false;
  bool _slideDirection = false; // false = left (productive), true = right (consumptive)
  final _activityController = TextEditingController();
  final _durationController = TextEditingController(text: '25');
  final _durationFocusNode = FocusNode();

  // ── Session management state
  late final SessionRepository _sessionRepository;
  late final StartSessionUseCase _startSessionUseCase;
  late final StopSessionUseCase _stopSessionUseCase;
  late final EvaluateSessionUseCase _evaluateSessionUseCase;
  bool _isStartingSession = false;
  // String? _startSessionError; // Debug field - unused

  // ── Category & Activity management
  late final CategoryActivityRepository _categoryActivityRepository;
  late final GetCategoriesUseCase _getCategoriesUseCase;
  late final CreateActivityUseCase _createActivityUseCase;
  List<Category> _categories = [];
  bool _isLoadingCategories = false;
  String? _selectedCategoryId;

  // ── Daily pulse data (productive/consumptive time)
  late final GetSessionsUseCase _getSessionsUseCase;
  late final GetSummaryDailyUseCase _getSummaryDailyUseCase;
  String _productiveTime = '0h 0m';
  String _consumptiveTime = '0h 0m';
  
  // ── Last session data (for Review Your Last Activity)
  String? _lastActivityName;
  String _lastActivityDuration = '0s';
  String? _lastSessionId;  // Store ID for evaluation

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _cardSlideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Slide animation: start at offset(0, 0) → slide to side
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0), // Will override direction
    ).animate(CurvedAnimation(
      parent: _cardSlideController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Initialize session use cases
    _sessionRepository = SessionRepositoryImpl();
    _startSessionUseCase = StartSessionUseCase(_sessionRepository);
    _stopSessionUseCase = StopSessionUseCase(_sessionRepository);
    _evaluateSessionUseCase = EvaluateSessionUseCase(_sessionRepository);

    // Initialize category & activity use cases
    _categoryActivityRepository = CategoryActivityRepositoryImpl();
    _getCategoriesUseCase = GetCategoriesUseCase(_categoryActivityRepository);
    _createActivityUseCase = CreateActivityUseCase(_categoryActivityRepository);

    // Initialize sessions use case for daily pulse
    _getSessionsUseCase = GetSessionsUseCase(_sessionRepository);
    
    // Initialize summary use case
    final summaryRepository = SummaryRepositoryImpl();
    _getSummaryDailyUseCase = GetSummaryDailyUseCase(summaryRepository);
    
    // Load categories and data
    _loadCategories();
    _loadSessions();
    _loadSummaryDaily();
    
    // Hide overlay when on dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TimerService>().hideOverlay();
      }
    });
  }

  /// Load categories dari API
  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      const noParams = NoParams();
      final categories = await _getCategoriesUseCase.call(noParams);

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
          // Set first category as default
          if (categories.isNotEmpty) {
            _selectedCategoryId = categories[0].id;
            _selectedCategoryIndex = 0;
          }
        });
        print('✅ Categories loaded: ${categories.length} items');
      }
    } catch (e) {
      print('❌ Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  /// Load today's sessions - extract last unevaluated session for ActivityCard
  /// 
  /// API returns only sessions with is_productive == null (unevaluated)
  /// So we just need to get the last session from response
  Future<void> _loadSessions() async {
    try {
      final localStorageService = LocalStorageService();
      final userId = localStorageService.getGuestUserId();
      
      if (userId == null) {
        print('❌ User ID not found');
        return;
      }

      final response = await _getSessionsUseCase.call(
        GetSessionsParams(userId: userId),
      );

      if (!mounted) return;

      // API already filters to return only unevaluated sessions
      if (response.sessions.isNotEmpty) {
        final lastSession = response.sessions.last;
        
        setState(() {
          _lastSessionId = lastSession.sessionId;
          _lastActivityName = lastSession.activityName ?? lastSession.activityId;
          _lastActivityDuration = lastSession.duration != null 
              ? _formatDurationShort(lastSession.duration!)
              : '0s';
          _isLastSessionProductive = lastSession.isProductive;
        });

        print('✅ Last session loaded:');
        print('   - Session ID: $_lastSessionId');
        print('   - Activity: $_lastActivityName');
        print('   - Duration: $_lastActivityDuration');
      } else {
        // No unevaluated sessions - show empty state
        setState(() {
          _lastSessionId = null;
          _lastActivityName = null;
          _lastActivityDuration = '0s';
          _isLastSessionProductive = null;
        });
        
        print('✅ No unevaluated sessions found - showing empty state');
      }
    } catch (e) {
      print('❌ Error loading sessions: $e');
    }
  }

  /// Load daily summary (productive/non-productive time totals)
  Future<void> _loadSummaryDaily() async {
    try {
      final localStorageService = LocalStorageService();
      final userId = localStorageService.getGuestUserId();
      
      if (userId == null) {
        print('❌ User ID not found');
        return;
      }

      final response = await _getSummaryDailyUseCase.call(
        GetSummaryDailyParams(userId: userId),
      );

      if (!mounted) return;

      // Convert seconds to "Xh Ym" format
      final productiveTime = _formatDuration(response.productiveTime);
      final consumptiveTime = _formatDuration(response.nonProductiveTime);

      setState(() {
        _productiveTime = productiveTime;
        _consumptiveTime = consumptiveTime;
      });

      print('✅ Daily summary loaded:');
      print('   - Productive: $productiveTime');
      print('   - Consumptive: $consumptiveTime');
    } catch (e) {
      print('❌ Error loading daily summary: $e');
      // Fallback ke hardcoded values jika error
      setState(() {
        _productiveTime = '0h 0m';
        _consumptiveTime = '0h 0m';
      });
    }
  }

  /// Format seconds to "Xh Ym" format
  /// 
  /// Example: 3665 seconds = "1h 1m"
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  /// Format seconds to short format
  /// 
  /// Example: 420 seconds = "420s" or "7m 0s"
  String _formatDurationShort(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  /// Handle session evaluation - mark as productive atau consumptive
  /// 
  /// Called when user clicks productive/consumptive buttons on ActivityCard
  /// 
  /// Flow:
  /// 1. Get current session ID dari SessionService
  /// 2. Call API /sessions/evaluate dengan isProductive flag
  /// 3. Clear the evaluated session from card immediately
  /// 4. Small delay to ensure API is fully updated
  /// 5. Reload sessions to find next unevaluated session
  /// 6. Update daily pulse data
  /// 7. Show success message
  Future<void> _handleEvaluateSession(bool isProductive) async {
    try {
      // 1️⃣ Get session ID dari last loaded session
      print('🔍 Checking for session to evaluate...');
      print('   - _lastSessionId: $_lastSessionId');

      if (_lastSessionId == null || _lastSessionId!.isEmpty) {
        print('⚠️ No session available for evaluation');
        _showErrorSnackbar('No session to evaluate. Please complete a session first.');
        return;
      }

      final evaluatedSessionId = _lastSessionId!;
      print('🔄 Evaluating session: $evaluatedSessionId (productive: $isProductive)');

      // Trigger slide animation (left for productive, right for consumptive)
      _slideDirection = !isProductive; // false = left (productive), true = right (consumptive)
      
      // Create new animation with correct direction
      final endOffset = _slideDirection ? const Offset(1.5, 0) : const Offset(-1.5, 0);
      _slideAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: endOffset,
      ).animate(CurvedAnimation(
        parent: _cardSlideController,
        curve: Curves.easeInOutCubic,
      ));

      // 2️⃣ Call API to evaluate session
      final evaluateResponse = await _evaluateSessionUseCase.call(
        EvaluateSessionParams(
          sessionId: evaluatedSessionId,
          isProductive: isProductive,
        ),
      );

      if (!mounted) return;

      print('✅ Session evaluated: ${evaluateResponse.evaluation}');

      // 3️⃣ Start card slide animation
      setState(() {
        _shouldAnimateCardExit = true;
      });
      
      await _cardSlideController.forward();

      if (!mounted) return;
      
      // 3️⃣.5 Clear the evaluated session after animation completes
      setState(() {
        _lastSessionId = null;
        _lastActivityName = null;
        _lastActivityDuration = '0s';
        _isLastSessionProductive = null;
        _shouldAnimateCardExit = false;
      });
      
      // Reset animation controller
      _cardSlideController.reset();

      // 4️⃣ Reload sessions to load next unevaluated session
      await _loadSessions();

      // 5️⃣ Reload daily summary to update pulse data
      await _loadSummaryDaily();

      // 6️⃣ Show success message
      if (mounted) {
        final message = isProductive
            ? '✅ Marked as productive!'
            : '✅ Marked as consumptive!';

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(milliseconds: 1500),
            ),
          );
      }
    } catch (e) {
      print('❌ Error evaluating session: $e');
      if (mounted) {
        _showErrorSnackbar('Failed to save evaluation. Please try again.');
      }
    }
  }

  Future<void> _navigateWithLoading(String route, int targetIndex) async {
    if (_isNavigating || targetIndex == 0) return;

    // Show overlay when navigating away from dashboard
    context.read<TimerService>().showOverlay();

    setState(() {
      _isNavigating = true;
      _navPreviewIndex = targetIndex;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    context.go(route);
  }

  /// Handle session start saat "Initiate Flow" diklik
  /// 
  /// Flow:
  /// 1. Get userId dari LocalStorageService
  /// 2. Create activity via API
  /// 3. Call API /sessions/start untuk create session
  /// 4. Save session ID ke SessionService (in-memory)
  /// 5. Start timer di TimerService
  Future<void> _handleInitiateFlow() async {
    if (_isStartingSession) return;

    setState(() {
      _isStartingSession = true;
    });

    try {
      // 1️⃣ Get userId dari local storage
      final localStorage = LocalStorageService();
      final userId = localStorage.getGuestUserId();

      if (userId == null) {
        _showErrorSnackbar('Error: User ID not found. Please login again.');
        setState(() => _isStartingSession = false);
        return;
      }

      print('🔄 Initiating flow for user: $userId');

      // Get category ID (use selected or default to first)
      final categoryId = _selectedCategoryId ?? _categories.firstOrNull?.id;
      
      if (categoryId == null) {
        _showErrorSnackbar('Error: No category available. Please try again.');
        setState(() => _isStartingSession = false);
        return;
      }

      // 2️⃣ Create activity
      final activityName = _activityController.text.isEmpty
          ? 'Deep Work Session'
          : _activityController.text;

      final activity = await _createActivityUseCase.call(
        CreateActivityParams(
          name: activityName,
          userId: userId,
          categoryId: categoryId,
        ),
      );

      if (!mounted) return;

      print('✅ Activity created: ${activity.id}');

      // 3️⃣ Call API to start session (with activity ID)
      final startResponse = await _startSessionUseCase.call(
        StartSessionParams(
          userId: userId,
          activityId: activity.id,
        ),
      );

      if (!mounted) return;

      // 4️⃣ Save session ke SessionService (in-memory)
      final sessionService = SessionService();
      
      print('📝 StartResponse details:');
      print('   - sessionId: ${startResponse.sessionId}');
      print('   - startedAt: ${startResponse.startedAt}');
      
      if (startResponse.sessionId.isEmpty) {
        print('❌ Session ID is empty from API response!');
        _showErrorSnackbar('Error: Invalid session response. Please try again.');
        setState(() => _isStartingSession = false);
        return;
      }
      
      sessionService.setSessionStarted(
        response: startResponse,
        activityId: activity.id,  // Use activity.id, not activity.name
      );

      // 5️⃣ Start timer
      final durationMinutes = int.tryParse(_durationController.text) ?? 25;
      final timerService = context.read<TimerService>();
      
      timerService.startTimer(
        activityName: activityName,
        durationMinutes: durationMinutes,
        isSetDuration: _isSetDuration,
      );

      // 5️⃣.5 Set callback: ketika timer natural completion, auto-stop session
      timerService.setOnTimerComplete(() {
        print('⏱️ Timer completed! Auto-stopping session...');
        _handleStopSession();
      });

      print('✅ Session started and timer initiated');

      setState(() {
        _isStartingSession = false;
      });
    } catch (e) {
      print('❌ Error initiating flow: $e');
      if (mounted) {
        setState(() {
          _isStartingSession = false;
        });
        _showErrorSnackbar('Failed to initiate flow. Please try again.');
      }
    }
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Handle session stop saat user klik "Complete" atau timer selesai
  /// 
  /// Flow:
  /// 1. Get session ID dari SessionService
  /// 2. Call API /sessions/stop untuk hentikan session
  /// 3. Bersihkan session dari SessionService (in-memory)
  /// 4. Stop timer di TimerService
  /// 5. Reload sessions untuk tampilkan unevaluated session di card
  /// 6. Update daily pulse data
  Future<void> _handleStopSession() async {
    try {
      // 1️⃣ Get session ID dari in-memory service
      final sessionService = SessionService();
      final currentSessionId = sessionService.currentSessionId;

      if (currentSessionId == null) {
        print('⚠️ No active session found');
        return;
      }

      print('🔄 Stopping session: $currentSessionId');

      // 2️⃣ Call API to stop session
      final stopResponse = await _stopSessionUseCase.call(
        StopSessionParams(sessionId: currentSessionId),
      );

      if (!mounted) return;

      print('✅ Session stopped: Duration ${stopResponse.duration}s');

      // 3️⃣ Bersihkan session dari in-memory
      sessionService.clearSession();

      // 4️⃣ Stop timer di UI
      final timerService = context.read<TimerService>();
      timerService.stopTimer();

      // 5️⃣ Reset UI fields
      if (mounted) {
        setState(() {
          _isLastSessionProductive = null; // Reset untuk review baru
          _activityController.clear();
          _durationController.text = '25';
        });
      }

      // 6️⃣ Load sessions untuk tampilkan unevaluated session
      await _loadSessions();

      // 7️⃣ Update daily pulse
      await _loadSummaryDaily();

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('✅ Session completed! Mark as productive or consumptive.'),
              duration: Duration(seconds: 2),
            ),
          );
      }
    } catch (e) {
      print('❌ Error stopping session: $e');
      if (mounted) {
        _showErrorSnackbar('Failed to stop session. Please try again.');
      }
    }
  }

  @override
  void dispose() {
    _activityController.dispose();
    _durationController.dispose();
    _durationFocusNode.dispose();
    _cardSlideController.dispose();
    super.dispose();
  }


  // ── Category data ──────────────────────────────────────────────────────────

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
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: Consumer<TimerService>(
                        builder: (context, timerService, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 420),
                                reverseDuration: const Duration(milliseconds: 320),
                                layoutBuilder: (widget, list) =>
                                    widget ?? const SizedBox(),
                                transitionBuilder: (child, animation) {
                                  // Entry animation - subtle fade + scale only
                                  final fadeAnimation =
                                      Tween<double>(begin: 0.0, end: 1.0).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutQuint,
                                        ),
                                      );

                                  // Subtle scale effect
                                  final scaleAnimation =
                                      Tween<double>(begin: 0.92, end: 1.0).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutQuart,
                                        ),
                                      );

                                  return FadeTransition(
                                    opacity: fadeAnimation,
                                    child: ScaleTransition(
                                      scale: scaleAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: timerService.isRunning
                                    ? _buildCurrentActivityCard()
                                    : _buildNewActivityCard(),
                              ),

                          const SizedBox(height: 24),

                          // ── REVIEW YOUR LAST ACTIVITY ─────────────────────────
                          _buildSectionLabel('REVIEW YOUR LAST ACTIVITY'),
                          const SizedBox(height: 12),
                          
                          // Show ActivityCard if there's a session available
                          // With slide animation on exit
                          _lastSessionId != null
                              ? ClipRect(
                                  child: SlideTransition(
                                    position: _shouldAnimateCardExit ? _slideAnimation : AlwaysStoppedAnimation(Offset.zero),
                                    child: ActivityCard(
                                      activityName: _lastActivityName ?? 'Activity',
                                      duration: _lastActivityDuration,
                                      isProductiveSelected: _isLastSessionProductive,
                                      onProductiveTap: () => _handleEvaluateSession(true),
                                      onConsumptiveTap: () => _handleEvaluateSession(false),
                                    ),
                                  ),
                                )
                              : _buildEmptyActivityPlaceholder(),

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
                                  duration: _productiveTime,
                                  iconAsset:
                                      'assets/icons/dashboard/Icon-6.png',
                                  isGradient: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DailyPulseCard(
                                  title: 'Drifting',
                                  subtitle: 'Passive Consumption',
                                  duration: _consumptiveTime,
                                  iconAsset:
                                      'assets/icons/dashboard/Icon-7.png',
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
                            childAspectRatio: 0.85,
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
                          );
                        },
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

  /// Empty state placeholder untuk ActivityCard
  /// 
  /// Ditampilkan ketika belum ada completed session
  Widget _buildEmptyActivityPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 40,
            color: const Color(0xFFB0B0B0),
          ),
          const SizedBox(height: 12),
          Text(
            'No activity yet',
            style: AppTextStyles.labelLarge.copyWith(
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Complete a session to review it here',
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF999999),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
        fontSize: 14,
        fontWeight: FontWeight.w600,
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

  Widget _buildNewActivityCard() {
    return AppCard(
      key: const ValueKey('new-activity'),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      borderRadius: 30,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('NEW ACTIVITY'),
          const SizedBox(height: 14),
          AppTextField(
            hint: 'What are you doing now?',
            controller: _activityController,
            prefixIcon: Icons.edit_outlined,
          ),
          const SizedBox(height: 14),
          // Dynamic category buttons dari API
          _isLoadingCategories
              ? Center(
                  child: SizedBox(
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight.withOpacity(0.6),
                      ),
                    ),
                  ),
                )
              : Row(
                  children: List.generate(
                    _categories.length,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: i < _categories.length - 1 ? 8 : 0,
                        ),
                        child: CategoryButton(
                          label: _categories[i].name,
                          icon: (_categories[i].name).toIconData(),
                          isSelected: _selectedCategoryIndex == i,
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = i;
                              _selectedCategoryId = _categories[i].id;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 16),
          _buildSectionLabel('DURATION MODE'),
          const SizedBox(height: 10),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixText: 'MIN',
                        suffixStyle: AppTextStyles.labelLarge.copyWith(
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
          SizedBox(
            width: double.infinity,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF15157D), AppColors.primaryLight],
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
                  onTap: _isStartingSession ? null : _handleInitiateFlow,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isStartingSession
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                        const SizedBox(width: 6),
                        Text(
                          _isStartingSession ? 'Starting...' : 'Initiate Flow',
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
    );
  }

  Widget _buildCurrentActivityCard() {
    return Consumer<TimerService>(
      builder: (context, timerService, _) {
        // Only show if timer is running
        if (!timerService.isRunning) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            // Background Container
            Container(
              key: const ValueKey('current-activity'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF15157D), const Color(0xFF841CD8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF841CD8).withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label with circle indicator
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'CURRENT ACTIVITY',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Activity name
                  Text(
                    timerService.currentActivityName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Session duration with adjustment buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Session duration: ${timerService.getDisplayDuration()}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (timerService.isSetDuration)
                        Row(
                          children: [
                            // -5m button
                            GestureDetector(
                              onTap: () => timerService.adjustDuration(-5),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '-5m',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // +5m button
                            GestureDetector(
                              onTap: () => timerService.adjustDuration(5),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+5m',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 28),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => timerService.pauseTimer(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              timerService.isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              size: 20,
                              color: const Color(0xFF2E1A66),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timerService.isPaused ? 'Resume' : 'Pause',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: const Color(0xFF2E1A66),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleStopSession,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Complete',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
            // Lightning Icon Background
            Positioned(
          right: -20,
          top: -20,
          child: Icon(
            Icons.bolt,
            size: 180,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ],
    );
      },
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
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
