import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService extends ChangeNotifier {
  // Timer state
  bool _isRunning = false;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  int _totalDurationSeconds = 0; // 0 = count-up, >0 = countdown
  String _currentActivityName = '';
  bool _isSetDuration = true;
  bool _isOverlayVisible = true; // New: track overlay visibility

  // Timer reference
  Timer? _sessionTimer;

  // Getters
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  int get elapsedSeconds => _elapsedSeconds;
  int get totalDurationSeconds => _totalDurationSeconds;
  String get currentActivityName => _currentActivityName;
  bool get isSetDuration => _isSetDuration;
  bool get isOverlayVisible => _isOverlayVisible;

  // Display time
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

  // Start timer
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

  // Pause timer
  void pauseTimer() {
    if (!_isRunning) return;
    _isPaused = !_isPaused;
    notifyListeners();
  }

  // Stop timer
  void stopTimer() {
    _sessionTimer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _elapsedSeconds = 0;
    _totalDurationSeconds = 0;
    _currentActivityName = '';
    notifyListeners();
  }

  // Adjust duration
  void adjustDuration(int minutesDelta) {
    if (!_isRunning) return;
    _totalDurationSeconds += (minutesDelta * 60);
    if (_totalDurationSeconds < 60) {
      _totalDurationSeconds = 60; // Minimum 1 minute
    }
    notifyListeners();
  }

  // Toggle overlay visibility
  void toggleOverlayVisibility() {
    _isOverlayVisible = !_isOverlayVisible;
    notifyListeners();
  }

  // Show overlay
  void showOverlay() {
    _isOverlayVisible = true;
    notifyListeners();
  }

  // Hide overlay
  void hideOverlay() {
    _isOverlayVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
