/// 📦 Activity Session Models
/// 
/// Handles data structures untuk activity sessions API response

class ActivitySession {
  final String id;
  final String userId;
  final String activityId;
  final String activityName;
  final String categoryName;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // dalam seconds
  final bool? isProductive;
  final int? points;

  ActivitySession({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.activityName,
    required this.categoryName,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.isProductive,
    this.points,
  });

  /// 🔄 Convert dari JSON
  /// 
  /// API return snake_case, kita map ke camelCase
  /// user_id → userId, activity_name → activityName, dll
  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      // ✅ Map snake_case dari API ke camelCase properties
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      activityId: json['activity_id'] as String? ?? '',
      activityName: json['activity_name'] as String? ?? 'NO_NAME',
      categoryName: json['category_name'] as String? ?? 'NO_CATEGORY',
      startTime: DateTime.parse(json['start_time'] as String? ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['end_time'] as String? ?? DateTime.now().toIso8601String()),
      duration: json['duration'] as int? ?? 0,
      isProductive: json['is_productive'] as bool?,
      points: json['points'] as int?,
    );
  }

  /// ⏰ Get duration dalam minutes
  int get durationInMinutes => duration ~/ 60;

  /// ⏰ Get start time dalam format "HH:mm AM/PM"
  String get formattedStartTime {
    final hour = startTime.hour > 12 ? startTime.hour - 12 : startTime.hour;
    final meridiem = startTime.hour >= 12 ? 'PM' : 'AM';
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $meridiem';
  }

  /// ⏰ Get duration dalam format "45 MINS" atau "1 H 30 MIN"
  String get formattedDuration {
    final minutes = durationInMinutes;
    if (minutes < 60) {
      return '$minutes MINS';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours H';
    }
    return '$hours H ${mins} MIN';
  }
}

class ActivitySessionResponse {
  final List<ActivitySession> sessions;

  ActivitySessionResponse({required this.sessions});

  /// 🔄 Convert dari JSON array
  factory ActivitySessionResponse.fromJson(List<dynamic> json) {
    try {
      final sessions = json
          .map((item) => ActivitySession.fromJson(item as Map<String, dynamic>))
          .toList();
      return ActivitySessionResponse(sessions: sessions);
    } catch (e) {
      print('❌ Error parsing ActivitySessionResponse: $e');
      rethrow;
    }
  }
}
