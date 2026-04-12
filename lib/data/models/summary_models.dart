/// Response dari GET /summary/daily
class SummaryDailyResponse {
  /// Total productive time dalam detik
  final int productiveTime;
  
  /// Total non-productive time dalam detik
  final int nonProductiveTime;
  
  /// Points today
  final int? points;
  
  /// Motivational message
  final String? message;

  SummaryDailyResponse({
    required this.productiveTime,
    required this.nonProductiveTime,
    this.points,
    this.message,
  });

  factory SummaryDailyResponse.fromJson(Map<String, dynamic> json) {
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
      return SummaryDailyResponse(
        productiveTime: parseIntOrString(json['productive_time']) ?? 0,
        nonProductiveTime: parseIntOrString(json['non_productive_time']) ?? 0,
        points: parseIntOrString(json['points']),
        message: json['message'],
      );
    } catch (e) {
      print('❌ Error parsing SummaryDailyResponse: $e');
      print('📝 JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() => 'SummaryDailyResponse(productive: $productiveTime, nonProductive: $nonProductiveTime, points: $points)';
}

/// ─────────────────────────────────────────────────────────────────────
/// 📊 WEEKLY SUMMARY MODELS
/// 
/// Response dari GET /summary/weekly?userId={userId}&date={date}
/// Returns: List of daily summaries untuk satu minggu
/// ─────────────────────────────────────────────────────────────────────

/// Single day summary within weekly data
/// 
/// Represents one day's productivity metrics
/// Part of WeeklySummaryResponse (array of these)
class WeeklySummaryDay {
  /// Date dalam format YYYY-MM-DD (e.g., "2026-04-06")
  final String date;
  
  /// Productive time dalam detik
  final int productiveTime;
  
  /// Non-productive time dalam detik
  final int nonProductiveTime;

  WeeklySummaryDay({
    required this.date,
    required this.productiveTime,
    required this.nonProductiveTime,
  });

  factory WeeklySummaryDay.fromJson(Map<String, dynamic> json) {
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
      return null;
    }

    try {
      return WeeklySummaryDay(
        date: json['date'] ?? '',
        productiveTime: parseIntOrString(json['productive_time']) ?? 0,
        nonProductiveTime: parseIntOrString(json['non_productive_time']) ?? 0,
      );
    } catch (e) {
      print('❌ Error parsing WeeklySummaryDay: $e');
      print('📝 JSON: $json');
      rethrow;
    }
  }

  /// Convert productive_time dari detik ke hours (double)
  /// Contoh: 3600 detik → 1.0 hour
  double get productiveHours => productiveTime / 3600.0;

  /// Convert non_productive_time dari detik ke hours (double)
  /// Contoh: 7200 detik → 2.0 hours
  double get nonProductiveHours => nonProductiveTime / 3600.0;

  @override
  String toString() => 'WeeklySummaryDay(date: $date, productive: ${productiveHours}h, nonProductive: ${nonProductiveHours}h)';
}

/// Response dari GET /summary/weekly
/// 
/// Contains array of daily summaries untuk satu minggu
/// API Response format:
/// [
///   { "date": "2026-04-06", "productive_time": 0, "non_productive_time": 0 },
///   { "date": "2026-04-07", "productive_time": 1800, "non_productive_time": 0 },
///   ...
/// ]
class WeeklySummaryResponse {
  /// List of daily summaries (biasanya 7 hari)
  final List<WeeklySummaryDay> days;

  WeeklySummaryResponse({
    required this.days,
  });

  factory WeeklySummaryResponse.fromJson(List<dynamic> json) {
    try {
      final days = json
          .map((item) => WeeklySummaryDay.fromJson(item as Map<String, dynamic>))
          .toList();
      
      print('✅ WeeklySummaryResponse parsed: ${days.length} days');
      return WeeklySummaryResponse(days: days);
    } catch (e) {
      print('❌ Error parsing WeeklySummaryResponse: $e');
      print('📝 JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() => 'WeeklySummaryResponse(days: ${days.length})';
}
