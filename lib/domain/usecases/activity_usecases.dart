/// 📦 Activity Use Cases
/// 
/// Business logic layer untuk activity operations

import 'package:lucid_state_app/domain/usecases/base_usecase.dart';
import 'package:lucid_state_app/data/models/activity_models.dart';
import 'package:lucid_state_app/data/repositories/activity_repository.dart';

class GetActivitySessionsParams {
  final String userId;
  final String date;
  final String? categoryId;

  GetActivitySessionsParams({
    required this.userId,
    required this.date,
    this.categoryId,
  });
}

class GetActivitySessionsUseCase
    extends UseCase<ActivitySessionResponse, GetActivitySessionsParams> {
  final IActivityRepository _repository;

  GetActivitySessionsUseCase(this._repository);

  @override
  Future<ActivitySessionResponse> call(GetActivitySessionsParams params) async {
    return await _repository.getActivitySessions(
      userId: params.userId,
      date: params.date,
      categoryId: params.categoryId,
    );
  }
}
