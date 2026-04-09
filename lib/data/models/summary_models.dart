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
