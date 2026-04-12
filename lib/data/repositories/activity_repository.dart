/// 📦 Activity Repository
/// 
/// Data access layer untuk activity sessions endpoints

import 'package:lucid_state_app/core/api/api_client.dart';
import 'package:lucid_state_app/core/api/config.dart';
import 'package:lucid_state_app/data/models/activity_models.dart';

abstract class IActivityRepository {
  /// 📋 Get activity sessions untuk user pada specific date
  Future<ActivitySessionResponse> getActivitySessions({
    required String userId,
    required String date,
    String? categoryId,
  });
}

class ActivityRepositoryImpl implements IActivityRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<ActivitySessionResponse> getActivitySessions({
    required String userId,
    required String date,
    String? categoryId,
  }) async {
    try {
      print('📋 Getting activity sessions for user: $userId, date: $date');
      
      // 📍 Build endpoint with query parameters
      String endpoint = '${AppConfig.baseUrl}/users/$userId/activity-sessions?date=$date';
      if (categoryId != null && categoryId.isNotEmpty) {
        endpoint += '&categoryId=$categoryId';
      }

      print('   📍 Endpoint: $endpoint');

      // 📨 Make request
      final response = await _apiClient.get(endpoint);

      print('   ✅ Response status: ${response.statusCode}');

      // 🔍 Check jika response punya wrapper "data"
      dynamic data = response.data;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      // 📦 Parse response
      if (data is List) {
        final parsedResponse = ActivitySessionResponse.fromJson(data);
        return parsedResponse;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('   ❌ Error getting activity sessions: $e');
      rethrow;
    }
  }
}
