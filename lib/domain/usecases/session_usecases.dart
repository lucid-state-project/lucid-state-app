import 'package:lucid_state_app/data/models/session_models.dart';
import 'package:lucid_state_app/data/repositories/session_repository.dart';
import 'package:lucid_state_app/domain/usecases/base_usecase.dart';

// ============================================================================

/// Use case untuk start session
/// 
/// Panggilnya: await StartSessionUseCase(repository).call(StartSessionParams(...))
class StartSessionUseCase extends UseCase<SessionStartResponse, StartSessionParams> {
  final SessionRepository repository;

  StartSessionUseCase(this.repository);

  @override
  Future<SessionStartResponse> call(StartSessionParams params) async {
    return repository.startSession(
      userId: params.userId,
      activityId: params.activityId,
    );
  }
}

/// Parameters untuk start session
class StartSessionParams {
  final String userId;
  final String activityId;

  StartSessionParams({
    required this.userId,
    required this.activityId,
  });
}

// ============================================================================

/// Use case untuk stop session
/// 
/// Panggilnya: await StopSessionUseCase(repository).call(StopSessionParams(...))
class StopSessionUseCase extends UseCase<SessionStopResponse, StopSessionParams> {
  final SessionRepository repository;

  StopSessionUseCase(this.repository);

  @override
  Future<SessionStopResponse> call(StopSessionParams params) async {
    return repository.stopSession(sessionId: params.sessionId);
  }
}

/// Parameters untuk stop session
class StopSessionParams {
  final String sessionId;

  StopSessionParams({required this.sessionId});
}

// ============================================================================

/// Use case untuk evaluate session
/// 
/// Panggilnya: await EvaluateSessionUseCase(repository).call(EvaluateSessionParams(...))
class EvaluateSessionUseCase
    extends UseCase<SessionEvaluateResponse, EvaluateSessionParams> {
  final SessionRepository repository;

  EvaluateSessionUseCase(this.repository);

  @override
  Future<SessionEvaluateResponse> call(EvaluateSessionParams params) async {
    return repository.evaluateSession(
      sessionId: params.sessionId,
      isProductive: params.isProductive,
    );
  }
}

/// Parameters untuk evaluate session
class EvaluateSessionParams {
  final String sessionId;
  final bool isProductive;

  EvaluateSessionParams({
    required this.sessionId,
    required this.isProductive,
  });
}

// ============================================================================

/// Use case untuk get sessions
/// 
/// Panggilnya: await GetSessionsUseCase(repository).call(GetSessionsParams(userId: '...'))
class GetSessionsUseCase extends UseCase<SessionListResponse, GetSessionsParams> {
  final SessionRepository repository;

  GetSessionsUseCase(this.repository);

  @override
  Future<SessionListResponse> call(GetSessionsParams params) async {
    return repository.getSessions(userId: params.userId);
  }
}

/// Parameters untuk get sessions
class GetSessionsParams {
  final String userId;

  GetSessionsParams({required this.userId});
}

// ============================================================================
