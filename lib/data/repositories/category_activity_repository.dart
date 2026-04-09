import '../../core/api/api_client.dart';
import '../../core/api/config.dart';
import '../../core/api/exceptions.dart';
import '../models/category_activity_models.dart';

/// Repository pattern untuk category dan activity management
abstract class CategoryActivityRepository {
  /// Get all categories
  /// 
  /// Returns: List<Category>
  /// Throws: Exception jika gagal
  Future<List<Category>> getCategories();

  /// Create new activity
  /// 
  /// Returns: Activity yang sudah created
  /// Throws: Exception jika gagal
  Future<Activity> createActivity({
    required String name,
    required String userId,
    required String categoryId,
  });
}

/// Implementasi repository
class CategoryActivityRepositoryImpl implements CategoryActivityRepository {
  final ApiClient _apiClient;

  CategoryActivityRepositoryImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  /// Get categories
  /// 
  /// Endpoint: GET /categories
  /// Response: [{ "id": "...", "name": "Focus" }, ...]
  @override
  Future<List<Category>> getCategories() async {
    try {
      print('📋 [GET] Categories List');

      final response = await _apiClient.get(AppConfig.categories);

      if (response.data != null) {
        List<Category> categories = [];

        // Handle berbagai format response
        if (response.data is List) {
          // Direct array response
          categories = (response.data as List)
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          
          // Check for wrapped response
          if (data['categories'] is List) {
            categories = (data['categories'] as List)
                .map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList();
          } else if (data['data'] is List) {
            categories = (data['data'] as List)
                .map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }

        print('✅ Categories loaded: ${categories.length} items');
        for (final cat in categories) {
          print('   └─ ${cat.name} (${cat.id})');
        }
        
        return categories;
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Get categories error: $e');
      rethrow;
    }
  }

  /// Create activity
  /// 
  /// Endpoint: POST /activities
  /// Body: { "name": "...", "user_id": "...", "category_id": "..." }
  /// Response: { "id": "...", "name": "...", "user_id": "...", "category_id": "..." }
  @override
  Future<Activity> createActivity({
    required String name,
    required String userId,
    required String categoryId,
  }) async {
    try {
      final request = CreateActivityRequest(
        name: name,
        userId: userId,
        categoryId: categoryId,
      );

      print('📝 [POST] Create Activity');
      print('   name: $name');
      print('   userId: $userId');
      print('   categoryId: $categoryId');

      final response = await _apiClient.post(
        AppConfig.activities,
        data: request.toJson(),
      );

      if (response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data
            : response.data['data'] ?? response.data;

        if (data is Map<String, dynamic>) {
          final activity = Activity.fromJson(data);
          print('✅ Activity created: ${activity.toString()}');
          return activity;
        }
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Create activity error: $e');
      rethrow;
    }
  }
}
