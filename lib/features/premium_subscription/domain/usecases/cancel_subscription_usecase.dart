import '../repositories/subscription_repository.dart';

class CancelSubscriptionUseCase {
  final SubscriptionRepository repository;

  CancelSubscriptionUseCase(this.repository);

  Future<DateTime> call() {
    return repository.cancelSubscription();
  }
}