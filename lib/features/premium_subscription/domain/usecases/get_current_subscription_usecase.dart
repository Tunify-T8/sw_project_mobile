import '../entities/current_subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetCurrentSubscriptionUseCase {
  final SubscriptionRepository repository;

  GetCurrentSubscriptionUseCase(this.repository);

  Future<CurrentSubscriptionEntity> call() {
    return repository.getCurrentSubscription();
  }
}