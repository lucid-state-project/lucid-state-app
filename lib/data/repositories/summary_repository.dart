import '../../core/api/api_client.dart';
import '../../core/api/config.dart';
import '../../core/api/exceptions.dart';
import '../models/summary_models.dart';

/// Repository pattern untuk summary management
/// 
/// Menangani semua API calls yang berhubungan dengan summary dan stats
abstract class SummaryRepository {
  /// Get daily summary (productive/non-productive time untuk hari ini)
  /// 
  /// Parameters: userId - ID pengguna
  /// Returns: SummaryDailyResponse dengan totals dan motivational message
  /// Throws: Exception jika gagal
  Future<SummaryDailyResponse> getSummaryDaily({required String userId});

  /// Get weekly summary (productive/non-productive time untuk 7 hari)
  /// 
  /// Parameters:
  ///   - userId: ID pengguna
  ///   - date: Date untuk week calculation (format: YYYY-MM-DD)
  ///           API akan return data untuk minggu yang berisi date ini
  /// Returns: WeeklySummaryResponse (list of 7 days dengan metrics)
  /// Throws: Exception jika gagal
  Future<WeeklySummaryResponse> getSummaryWeekly({
    required String userId,
    required String date,
  });
}

/// Implementasi SummaryRepository
class SummaryRepositoryImpl implements SummaryRepository {
  final ApiClient _apiClient;

  SummaryRepositoryImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  /// Get daily summary
  /// 
  /// Endpoint: GET /summary/daily
  /// Response: { "productive_time": ..., "non_productive_time": ..., "points": ..., "message": "..." }
  @override
  Future<SummaryDailyResponse> getSummaryDaily({required String userId}) async {
    try {
      print('📊 [GET] Summary Daily (userId: $userId)');

      final response = await _apiClient.get(
        AppConfig.summaryDaily,
        queryParams: {'userId': userId},
      );

      print('📝 Raw response data: ${response.data}');
      print('📝 Response type: ${response.data.runtimeType}');

      if (response.data != null) {
        dynamic data = response.data;
        
        // If response is wrapped in data key
        if (data is Map<String, dynamic> && data['data'] != null) {
          print('📝 Response has data wrapper');
          data = data['data'];
        }

        print('📝 Final data to parse: $data');
        final summaryResponse = SummaryDailyResponse.fromJson(data as Map<String, dynamic>);
        print('✅ Summary Daily response: ${summaryResponse.toString()}');
        return summaryResponse;
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Get summary daily error: $e');
      rethrow;
    }
  }

  /// Get weekly summary
  /// 
  /// Endpoint: GET /summary/weekly?userId={userId}&date={date}
  /// Query Params:
  ///   - userId: User ID (required)
  ///   - date: Target date untuk week calculation, format YYYY-MM-DD (required)
  /// Response: Array of daily summaries
  /// [
  ///   { "date": "2026-04-06", "productive_time": 0, "non_productive_time": 0 },
  ///   { "date": "2026-04-07", "productive_time": 1800, "non_productive_time": 900 },
  ///   ...
  /// ]
  @override
  Future<WeeklySummaryResponse> getSummaryWeekly({
    required String userId,
    required String date,
  }) async {
    try {
      print('📊 [GET] Summary Weekly');
      print('   └─ userId: $userId');
      print('   └─ date: $date');

      // 🔗 Call API dengan query parameters
      final response = await _apiClient.get(
        AppConfig.summaryWeekly,
        queryParams: {
          'userId': userId,
          'date': date,
        },
      );

      print('📝 Raw response data: ${response.data}');
      print('📝 Response type: ${response.data.runtimeType}');

      if (response.data != null) {
        dynamic data = response.data;

        // 📋 Handle response wrapping
        // Sometimes API returns { "data": [...] }, sometimes just [...]
        if (data is Map<String, dynamic> && data['data'] != null) {
          print('📋 Response has data wrapper');
          data = data['data'];
        }

        print('📋 Final data to parse: $data');

        // ✅ Parse as list and return WeeklySummaryResponse
        if (data is List) {
          final weeklySummary = WeeklySummaryResponse.fromJson(data);
          print('✅ Weekly summary response: ${weeklySummary.toString()}');
          return weeklySummary;
        }

        print('❌ Invalid response format (expected List): ${response.data}');
        throw ApiException(
          message: 'Invalid response format',
          code: 'INVALID_RESPONSE',
          statusCode: response.statusCode,
        );
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Get summary weekly error: $e');
      rethrow;
    }
  }
}
