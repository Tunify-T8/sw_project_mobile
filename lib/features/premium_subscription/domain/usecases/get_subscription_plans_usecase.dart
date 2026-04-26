import '../entities/subscription_plan_entity.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionPlansUseCase {
  final SubscriptionRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  Future<List<SubscriptionPlanEntity>> call() {
    return repository.getPlans();
  }
}