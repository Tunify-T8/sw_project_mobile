import '../../data/dto/cancel_subscription_response_dto.dart';
import '../repositories/subscription_repository.dart';

class CancelSubscriptionUseCase {
  final SubscriptionRepository repository;

  CancelSubscriptionUseCase(this.repository);

  Future<CancelSubscriptionResponseDto> call() {
    return repository.cancelSubscription();
  }
}
