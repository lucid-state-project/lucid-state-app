/// Base use case abstract class
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Empty parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
