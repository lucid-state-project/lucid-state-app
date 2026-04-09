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
}
