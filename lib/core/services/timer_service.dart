import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service managing timer functionality for activity tracking.
///
/// Provides methods to start, pause, stop, and adjust timers. Supports both
/// count-up mode (open-ended tracking) and countdown mode (fixed duration).
/// Manages visibility of the timer overlay widget.
///
/// This service extends [ChangeNotifier], making it compatible with the
/// Provider state management package for reactive UI updates.
///
/// Example usage:
/// ```dart
/// final timerService = context.read<TimerService>();
/// timerService.startTimer(
///   activityName: 'Meditation',
///   durationMinutes: 10,
///   isSetDuration: true,
/// );
/// ```
class TimerService extends ChangeNotifier {
  // Timer state variables
  bool _isRunning = false;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  int _totalDurationSeconds = 0; // 0 = count-up, >0 = countdown
  String _currentActivityName = '';
  bool _isSetDuration = true;
  bool _isOverlayVisible = true; // Tracks overlay visibility

  // Timer reference
  Timer? _sessionTimer;

  // ============================================================================
  // Getters
  // ============================================================================

  /// Whether the timer is currently running.
  bool get isRunning => _isRunning;

  /// Whether the timer is paused.
  bool get isPaused => _isPaused;

  /// Number of seconds elapsed since timer started.
  int get elapsedSeconds => _elapsedSeconds;

  /// Total duration in seconds (0 for count-up mode).
  int get totalDurationSeconds => _totalDurationSeconds;

  /// Name of the current activity being tracked.
  String get currentActivityName => _currentActivityName;

  /// Whether timer is in set-duration countdown mode.
  bool get isSetDuration => _isSetDuration;

  /// Whether the timer overlay is currently visible.
  bool get isOverlayVisible => _isOverlayVisible;

  // ============================================================================
  // Public Methods
  // ============================================================================

  /// Starts a new timer session.
  ///
  /// Initializes timer with given [activityName] and mode settings.
  /// Cancels any existing timer before starting a new one.
  ///
  /// Parameters:
  ///   - [activityName]: Name of the activity being tracked
  ///   - [durationMinutes]: Duration in minutes (for set-duration mode)
  ///   - [isSetDuration]: If true, timer counts down; if false, counts up
  ///
  /// Throws: No exceptions. Silently returns if timer already running.
  void startTimer({
    required String activityName,
    required int durationMinutes,
    required bool isSetDuration,
  }) {
    if (_isRunning) return; // Already running

    _isRunning = true;
    _isPaused = false;
    _currentActivityName = activityName;
    _elapsedSeconds = 0;
    _isSetDuration = isSetDuration;
    _totalDurationSeconds = isSetDuration ? durationMinutes * 60 : 0;

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _elapsedSeconds++;

        // Check if timer finished for Set Duration mode
        if (_isSetDuration &&
            _totalDurationSeconds > 0 &&
            _elapsedSeconds >= _totalDurationSeconds) {
          stopTimer();
          return;
        }

        notifyListeners();
      }
    });

    notifyListeners();
  }

  /// Pauses or resumes the timer.
  ///
  /// Toggles between paused and running states. Has no effect if timer
  /// is not currently running.
  void pauseTimer() {
    if (!_isRunning) return;
    _isPaused = !_isPaused;
    notifyListeners();
  }

  /// Stops the timer and resets all state.
  ///
  /// Cancels the internal timer, resets elapsed time, clears activity name,
  /// and resets all state flags to their initial values.
  void stopTimer() {
    _sessionTimer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _elapsedSeconds = 0;
    _totalDurationSeconds = 0;
    _currentActivityName = '';
    notifyListeners();
  }

  /// Adjusts the duration of a set-duration timer.
  ///
  /// Adds [minutesDelta] minutes to the total duration. Only works if
  /// timer is running. Enforces a minimum duration of 60 seconds.
  ///
  /// Parameters:
  ///   - [minutesDelta]: Minutes to add (can be negative for reduction)
  ///
  /// Returns nothing but triggers [notifyListeners] on successful adjustment.
  void adjustDuration(int minutesDelta) {
    if (!_isRunning) return;
    _totalDurationSeconds += (minutesDelta * 60);
    if (_totalDurationSeconds < 60) {
      _totalDurationSeconds = 60; // Minimum 1 minute
    }
    notifyListeners();
  }

  /// Toggles the visibility of the timer overlay widget.
  ///
  /// Useful for temporarily hiding the floating timer UI without stopping
  /// the timer itself. Triggers [notifyListeners] to rebuild dependent widgets.
  void toggleOverlayVisibility() {
    _isOverlayVisible = !_isOverlayVisible;
    notifyListeners();
  }

  /// Shows the timer overlay widget.
  ///
  /// Makes the floating timer UI visible. No-op if already visible.
  void showOverlay() {
    _isOverlayVisible = true;
    notifyListeners();
  }

  /// Hides the timer overlay widget.
  ///
  /// Makes the floating timer UI invisible. No-op if already hidden.
  /// Does NOT stop the timer; the timer continues running in the background.
  void hideOverlay() {
    _isOverlayVisible = false;
    notifyListeners();
  }

  /// Returns formatted display string for the timer.
  ///
  /// In countdown mode: displays remaining time as "XmYs"
  /// In count-up mode: displays elapsed time as "XmYs"
  ///
  /// Returns a string like "5m 30s" or "0m 45s"
  String getDisplayDuration() {
    if (_isSetDuration && _totalDurationSeconds > 0) {
      // Countdown timer
      final remaining = _totalDurationSeconds - _elapsedSeconds;
      final minutes = remaining ~/ 60;
      final secs = remaining % 60;
      return '${minutes}m ${secs}s';
    } else {
      // Count-up timer
      final minutes = _elapsedSeconds ~/ 60;
      final secs = _elapsedSeconds % 60;
      return '${minutes}m ${secs}s';
    }
  }

  // ============================================================================
  // Lifecycle
  // ============================================================================

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
