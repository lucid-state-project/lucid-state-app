/// Request untuk session start
/// 
/// Endpoint: POST /sessions/start
class SessionStartRequest {
  /// User ID dari storage
  final String userId;
  
  /// Activity ID yang dipilih user
  final String activityId;

  SessionStartRequest({
    required this.userId,
    required this.activityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'activity_id': activityId,
    };
  }
}

/// Response dari session start
class SessionStartResponse {
  /// Session ID untuk future requests
  final String sessionId;
  
  /// Timestamp kapan session dimulai
  final String? startedAt;

  SessionStartResponse({
    required this.sessionId,
    this.startedAt,
  });

  factory SessionStartResponse.fromJson(Map<String, dynamic> json) {
    try {
      return SessionStartResponse(
        sessionId: json['session_id'] ?? json['sessionId'] ?? '',
        startedAt: json['started_at'] ?? json['startedAt'],
      );
    } catch (e) {
      print('❌ Error parsing SessionStartResponse: $e');
      print('📝 JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() => 'SessionStartResponse(sessionId: $sessionId, startedAt: $startedAt)';
}

// ============================================================================

/// Request untuk session stop
/// 
/// Endpoint: POST /sessions/stop
class SessionStopRequest {
  /// Session ID yang ingin dihentikan
  final String sessionId;

  SessionStopRequest({
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
    };
  }
}

/// Response dari session stop
class SessionStopResponse {
  /// Session ID yang dihentikan
  final String sessionId;
  
  /// Durasi session dalam detik
  final int? duration;
  
  /// Timestamp kapan session berakhir
  final String? stoppedAt;

  SessionStopResponse({
    required this.sessionId,
    this.duration,
    this.stoppedAt,
  });

  factory SessionStopResponse.fromJson(Map<String, dynamic> json) {
    // Helper to parse both int and string to int
    int? parseIntOrString(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('⚠️ Failed to parse "$value" as int: $e');
          return null;
        }
      }
      print('⚠️ Unexpected type for int parsing: ${value.runtimeType} = $value');
      return null;
    }
    
    try {
      return SessionStopResponse(
        sessionId: json['session_id'] ?? json['sessionId'] ?? '',
        duration: parseIntOrString(json['duration']),
        stoppedAt: json['stopped_at'] ?? json['stoppedAt'],
      );
    } catch (e) {
      print('❌ Error parsing SessionStopResponse: $e');
      print('📝 JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() => 'SessionStopResponse(sessionId: $sessionId, duration: ${duration}s)';
}

// ============================================================================

/// Request untuk session evaluate
/// 
/// Endpoint: POST /sessions/evaluate
class SessionEvaluateRequest {
  /// Session ID yang dievaluasi
  final String sessionId;
  
  /// Apakah session productive? true = productive, false = consumptive
  final bool isProductive;

  SessionEvaluateRequest({
    required this.sessionId,
    required this.isProductive,
  });

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'is_productive': isProductive,
    };
  }
}

/// Response dari session evaluate
class SessionEvaluateResponse {
  /// Session ID yang dievaluasi
  final String sessionId;
  
  /// Hasil evaluasi (productive/consumptive)
  final String evaluation;
  
  /// Points yang didapat (jika applicable)
  final int? points;

  SessionEvaluateResponse({
    required this.sessionId,
    required this.evaluation,
    this.points,
  });

  factory SessionEvaluateResponse.fromJson(Map<String, dynamic> json) {
    // Helper to parse both int and string to int
    int? parseIntOrString(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('⚠️ Failed to parse "$value" as int: $e');
          return null;
        }
      }
      print('⚠️ Unexpected type for int parsing: ${value.runtimeType} = $value');
      return null;
    }
    
    try {
      return SessionEvaluateResponse(
        sessionId: json['session_id'] ?? json['sessionId'] ?? '',
        evaluation: json['evaluation'] ?? (json['is_productive'] == true ? 'productive' : 'consumptive'),
        points: parseIntOrString(json['points']),
      );
    } catch (e) {
      print('❌ Error parsing SessionEvaluateResponse: $e');
      print('📝 JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() => 'SessionEvaluateResponse(sessionId: $sessionId, evaluation: $evaluation, points: $points)';
}

// ============================================================================

/// Model untuk session data (dari GET /sessions)
class Session {
  /// Session ID
  final String sessionId;
  
  /// User ID
  final String userId;
  
  /// Activity ID
  final String activityId;
  
  /// Activity name
  final String? activityName;
  
  /// Category name
  final String? categoryName;
  
  /// Waktu mulai
  final String startedAt;
  
  /// Waktu selesai (null jika masih ongoing)
  final String? stoppedAt;
  
  /// Durasi dalam detik
  final int? duration;
  
  /// Apakah productive
  final bool? isProductive;
  
  /// Evaluation result
  final String? evaluation;

  Session({
    required this.sessionId,
    required this.userId,
    required this.activityId,
    this.activityName,
    this.categoryName,
    required this.startedAt,
    this.stoppedAt,
    this.duration,
    this.isProductive,
    this.evaluation,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    // Helper to parse both int and string to int
    int? parseIntOrString(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('⚠️ Failed to parse "$value" as int: $e');
          return null;
        }
      }
      print('⚠️ Unexpected type for int parsing: ${value.runtimeType} = $value');
      return null;
    }
    
    // Helper to safely parse bool
    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      return null;
    }
    
    try {
      return Session(
        sessionId: json['id'] ?? json['session_id'] ?? json['sessionId'] ?? '',
        userId: json['user_id'] ?? json['userId'] ?? '',
        activityId: json['activity_id'] ?? json['activityId'] ?? '',
        activityName: json['activity_name'],
        categoryName: json['category_name'],
        startedAt: json['start_time'] ?? json['started_at'] ?? json['startedAt'] ?? '',
        stoppedAt: json['end_time'] ?? json['stopped_at'] ?? json['stoppedAt'],
        duration: parseIntOrString(json['duration']),
        isProductive: parseBool(json['is_productive']),
        evaluation: json['evaluation'],
      );
    } catch (e) {
      print('❌ Error parsing Session: $e');
      print('📝 JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() => 'Session(sessionId: $sessionId, activityId: $activityId, duration: ${duration}s)';
}

/// Response dari GET /sessions
class SessionListResponse {
  /// List of sessions
  final List<Session> sessions;
  
  /// Total productive sessions
  final int? totalProductive;
  
  /// Total consumptive sessions
  final int? totalConsumptive;

  SessionListResponse({
    required this.sessions,
    this.totalProductive,
    this.totalConsumptive,
  });

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    List<Session> sessionsList = [];
    
    // Helper to parse both int and string to int
    int? parseIntOrString(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print('⚠️ Failed to parse "$value" as int: $e');
          return null;
        }
      }
      print('⚠️ Unexpected type for int parsing: ${value.runtimeType} = $value');
      return null;
    }
    
    try {
      // Handle different response formats
      if (json['sessions'] is List) {
        // Format: { sessions: [...] }
        sessionsList = (json['sessions'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => Session.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('⚠️ Error parsing sessions list: $e');
    }
    
    return SessionListResponse(
      sessions: sessionsList,
      totalProductive: parseIntOrString(json['total_productive']),
      totalConsumptive: parseIntOrString(json['total_consumptive']),
    );
  }

  @override
  String toString() => 'SessionListResponse(sessions: ${sessions.length}, productive: $totalProductive, consumptive: $totalConsumptive)';
}
