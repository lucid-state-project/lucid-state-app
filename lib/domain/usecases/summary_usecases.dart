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
