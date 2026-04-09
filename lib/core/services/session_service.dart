import 'package:lucid_state_app/data/models/session_models.dart';

/// Service untuk manage current session state
/// 
/// Menyimpan info session yang sedang berjalan di memory
/// (tidak persisten - reset saat app restart)
class SessionService {
  static final SessionService _instance = SessionService._internal();

  // ── Current session state
  String? _currentSessionId;
  String? _currentActivityId;
  DateTime? _sessionStartTime;
  SessionStartResponse? _sessionStartResponse;

  factory SessionService() {
    return _instance;
  }

  SessionService._internal();

  // ── GETTERS ───────────────────────────────────────────────────────────

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Get current activity ID
  String? get currentActivityId => _currentActivityId;

  /// Get session start time
  DateTime? get sessionStartTime => _sessionStartTime;

  /// Get current session response
  SessionStartResponse? get sessionStartResponse => _sessionStartResponse;

  /// Check apakah ada session yang sedang berjalan
  bool get hasActiveSession => _currentSessionId != null;

  /// Get elapsed time dalam detik
  int? get elapsedSeconds {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  // ── SETTERS ───────────────────────────────────────────────────────────

  /// Set session sebagai started
  /// 
  /// Call ini saat session start API berhasil
  void setSessionStarted({
    required SessionStartResponse response,
    required String activityId,
  }) {
    _currentSessionId = response.sessionId;
    _currentActivityId = activityId;
    _sessionStartTime = DateTime.now();
    _sessionStartResponse = response;

    print('✅ Session started in memory');
    print('   └─ Session ID: $_currentSessionId');
    print('   └─ Activity ID: $_currentActivityId');
    print('   └─ Start time: $_sessionStartTime');
  }

  /// Clear session state (saat session stop)
  void clearSession() {
    print('🗑️ Session cleared from memory');
    print('   └─ Previous session ID: $_currentSessionId');
    print('   └─ Elapsed time: $elapsedSeconds seconds');

    _currentSessionId = null;
    _currentActivityId = null;
    _sessionStartTime = null;
    _sessionStartResponse = null;
  }

  // ── HELPERS ───────────────────────────────────────────────────────────

  /// Get formatted elapsed time (MM:SS)
  String getFormattedElapsedTime() {
    final seconds = elapsedSeconds ?? 0;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Reset all session data (untuk logout atau clear)
  void resetAll() {
    _currentSessionId = null;
    _currentActivityId = null;
    _sessionStartTime = null;
    _sessionStartResponse = null;
    print('🔄 Session service reset');
  }
}
