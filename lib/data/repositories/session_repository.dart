import '../../core/api/api_client.dart';
import '../../core/api/config.dart';
import '../../core/api/exceptions.dart';
import '../models/session_models.dart';

/// Repository pattern untuk session management
/// 
/// Menangani semua API calls yang berhubungan dengan session tracking
abstract class SessionRepository {
  /// Start session untuk activity tertentu
  /// 
  /// Returns: SessionStartResponse dengan session_id
  /// Throws: Exception jika gagal
  Future<SessionStartResponse> startSession({
    required String userId,
    required String activityId,
  });

  /// Stop session yang sedang berjalan
  /// 
  /// Returns: SessionStopResponse dengan duration
  /// Throws: Exception jika gagal
  Future<SessionStopResponse> stopSession({
    required String sessionId,
  });

  /// Evaluate session - mark as productive or consumptive
  /// 
  /// [isProductive] - true = productive, false = consumptive
  /// Returns: SessionEvaluateResponse
  /// Throws: Exception jika gagal
  Future<SessionEvaluateResponse> evaluateSession({
    required String sessionId,
    required bool isProductive,
  });

  /// Get all sessions untuk user (usually today)
  /// 
  /// Parameters: userId - ID pengguna yang merekam session
  /// Returns: SessionListResponse dengan list of sessions
  /// Throws: Exception jika gagal
  Future<SessionListResponse> getSessions({required String userId});
}

/// Implementasi SessionRepository
class SessionRepositoryImpl implements SessionRepository {
  final ApiClient _apiClient;

  SessionRepositoryImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  /// Start session
  /// 
  /// Endpoint: POST /sessions/start
  /// Body: { "user_id": "...", "activity_id": "..." }
  /// Response: { "session_id": "..." }
  @override
  Future<SessionStartResponse> startSession({
    required String userId,
    required String activityId,
  }) async {
    try {
      final request = SessionStartRequest(
        userId: userId,
        activityId: activityId,
      );

      print('🚀 [POST] Sessions Start');
      print('   userId: $userId');
      print('   activityId: $activityId');

      final response = await _apiClient.post(
        AppConfig.sessionsStart,
        data: request.toJson(),
      );

      print('📝 Raw response: ${response.data}');
      print('📝 Response type: ${response.data.runtimeType}');

      if (response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data
            : response.data['data'] ?? response.data;

        print('📝 Parsed data: $data');

        if (data is Map<String, dynamic>) {
          final startResponse = SessionStartResponse.fromJson(data);
          print('✅ Sessions Start response: ${startResponse.toString()}');
          return startResponse;
        }
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Start session error: $e');
      rethrow;
    }
  }

  /// Stop session
  /// 
  /// Endpoint: POST /sessions/stop
  /// Body: { "session_id": "..." }
  /// Response: { "session_id": "...", "duration": ... }
  @override
  Future<SessionStopResponse> stopSession({
    required String sessionId,
  }) async {
    try {
      final request = SessionStopRequest(sessionId: sessionId);

      print('🛑 [POST] Sessions Stop');
      print('   sessionId: $sessionId');

      final response = await _apiClient.post(
        AppConfig.sessionsStop,
        data: request.toJson(),
      );

      if (response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data
            : response.data['data'] ?? response.data;

        if (data is Map<String, dynamic>) {
          final stopResponse = SessionStopResponse.fromJson(data);
          print('✅ Sessions Stop response: ${stopResponse.toString()}');
          return stopResponse;
        }
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Stop session error: $e');
      rethrow;
    }
  }

  /// Evaluate session
  /// 
  /// Endpoint: POST /sessions/evaluate
  /// Body: { "session_id": "...", "is_productive": true/false }
  /// Response: { "session_id": "...", "evaluation": "productive|consumptive" }
  @override
  Future<SessionEvaluateResponse> evaluateSession({
    required String sessionId,
    required bool isProductive,
  }) async {
    try {
      final request = SessionEvaluateRequest(
        sessionId: sessionId,
        isProductive: isProductive,
      );

      print('📊 [POST] Sessions Evaluate');
      print('   sessionId: $sessionId');
      print('   isProductive: $isProductive');

      final response = await _apiClient.post(
        AppConfig.sessionsEvaluate,
        data: request.toJson(),
      );

      if (response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data
            : response.data['data'] ?? response.data;

        if (data is Map<String, dynamic>) {
          final evalResponse = SessionEvaluateResponse.fromJson(data);
          print('✅ Sessions Evaluate response: ${evalResponse.toString()}');
          return evalResponse;
        }
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Evaluate session error: $e');
      rethrow;
    }
  }

  /// Get sessions
  /// 
  /// Endpoint: GET /sessions
  /// Response: { "sessions": [...], "total_productive": ..., "total_consumptive": ... }
  @override
  Future<SessionListResponse> getSessions({required String userId}) async {
    try {
      print('📋 [GET] Sessions List (userId: $userId)');

      final response = await _apiClient.get(
        AppConfig.sessionsList,
        queryParams: {'userId': userId},
      );

      print('📝 Raw response data: ${response.data}');
      print('📝 Response type: ${response.data.runtimeType}');

      if (response.data != null) {
        dynamic data = response.data;
        
        // If response is a list (array of sessions)
        if (data is List) {
          print('📝 Response is a list');
          final sessionsList = data as List<dynamic>;
          data = <String, dynamic>{'sessions': sessionsList};
        }
        // If response is a map (single session or wrapped)
        else if (data is Map<String, dynamic>) {
          print('📝 Response is a map with keys: ${data.keys}');
          
          // If it looks like a single session (has id, user_id, duration fields)
          if (data['id'] != null && data['user_id'] != null && data['duration'] != null) {
            print('📝 Detected single session object');
            // Wrap it in a sessions array
            final sessionData = data as Map<String, dynamic>;
            data = <String, dynamic>{'sessions': [sessionData]};
          }
          // If it already has 'sessions' key, use as-is
          else if (data['sessions'] != null) {
            print('📝 Response already has sessions array');
          }
          // Otherwise try data key
          else if (data['data'] != null) {
            print('📝 Response has data wrapper');
            final wrappedData = data['data'];
            if (wrappedData is List) {
              data = <String, dynamic>{'sessions': wrappedData as List<dynamic>};
            } else {
              data = wrappedData;
            }
          }
        }

        print('📝 Final data to parse: $data');
        final listResponse = SessionListResponse.fromJson(data as Map<String, dynamic>);
        print('✅ Sessions List response: ${listResponse.toString()}');
        return listResponse;
      }

      print('❌ Invalid response format: ${response.data}');
      throw ApiException(
        message: 'Invalid response format',
        code: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ Get sessions error: $e');
      rethrow;
    }
  }
}
