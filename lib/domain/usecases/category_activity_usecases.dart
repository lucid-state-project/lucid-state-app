import 'package:lucid_state_app/data/models/category_activity_models.dart';
import 'package:lucid_state_app/data/repositories/category_activity_repository.dart';
import 'package:lucid_state_app/domain/usecases/base_usecase.dart';

// ============================================================================

/// Use case untuk get categories
/// 
/// Panggilnya: await GetCategoriesUseCase(repository).call(NoParams())
class GetCategoriesUseCase extends UseCase<List<Category>, NoParams> {
  final CategoryActivityRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<List<Category>> call(NoParams params) async {
    return repository.getCategories();
  }
}

// ============================================================================

/// Use case untuk create activity
/// 
/// Panggilnya: await CreateActivityUseCase(repository).call(CreateActivityParams(...))
class CreateActivityUseCase extends UseCase<Activity, CreateActivityParams> {
  final CategoryActivityRepository repository;

  CreateActivityUseCase(this.repository);

  @override
  Future<Activity> call(CreateActivityParams params) async {
    return repository.createActivity(
      name: params.name,
      userId: params.userId,
      categoryId: params.categoryId,
    );
  }
}

/// Parameters untuk create activity
class CreateActivityParams {
  final String name;
  final String userId;
  final String categoryId;

  CreateActivityParams({
    required this.name,
    required this.userId,
    required this.categoryId,
  });
}

// ============================================================================
