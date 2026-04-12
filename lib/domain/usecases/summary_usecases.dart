import 'package:lucid_state_app/data/models/summary_models.dart';
import 'package:lucid_state_app/data/repositories/summary_repository.dart';
import 'package:lucid_state_app/domain/usecases/base_usecase.dart';

// ============================================================================

/// Use case untuk get daily summary
/// 
/// Panggilnya: await GetSummaryDailyUseCase(repository).call(GetSummaryDailyParams(userId: '...'))
class GetSummaryDailyUseCase extends UseCase<SummaryDailyResponse, GetSummaryDailyParams> {
  final SummaryRepository repository;

  GetSummaryDailyUseCase(this.repository);

  @override
  Future<SummaryDailyResponse> call(GetSummaryDailyParams params) async {
    return repository.getSummaryDaily(userId: params.userId);
  }
}

/// Parameters untuk get daily summary
class GetSummaryDailyParams {
  final String userId;

  GetSummaryDailyParams({required this.userId});
}

// ============================================================================

/// 📊 Use case untuk get weekly summary
/// 
/// Mengambil data produktivitas untuk 7 hari dalam sebuah minggu
/// 
/// Panggilnya: 
/// ```dart
/// await GetWeeklySummaryUseCase(repository).call(
///   GetWeeklySummaryParams(
///     userId: '...',
///     date: '2026-04-10'  // YYYY-MM-DD format
///   )
/// )
/// ```
class GetWeeklySummaryUseCase extends UseCase<WeeklySummaryResponse, GetWeeklySummaryParams> {
  final SummaryRepository repository;

  GetWeeklySummaryUseCase(this.repository);

  /// 🚀 Call weekly summary API
  /// 
  /// Flow:
  /// 1. Receive params dengan userId dan date
  /// 2. Pass ke repository.getSummaryWeekly()
  /// 3. API akan return array of 7 days data
  /// 4. Parse sebagai WeeklySummaryResponse
  /// 5. Return untuk display di UI
  @override
  Future<WeeklySummaryResponse> call(GetWeeklySummaryParams params) async {
    return repository.getSummaryWeekly(
      userId: params.userId,
      date: params.date,
    );
  }
}

/// 📋 Parameters untuk get weekly summary
/// 
/// Fields:
/// - userId: User ID untuk query
/// - date: Target date dalam format YYYY-MM-DD
///         API akan determine minggu mana berdasarkan date ini
class GetWeeklySummaryParams {
  final String userId;
  
  /// Date dalam format YYYY-MM-DD (e.g., "2026-04-10")
  /// Digunakan untuk determine minggu yang mana
  final String date;

  GetWeeklySummaryParams({
    required this.userId,
    required this.date,
  });

  @override
  String toString() => 'GetWeeklySummaryParams(userId: $userId, date: $date)';
}

// ============================================================================
