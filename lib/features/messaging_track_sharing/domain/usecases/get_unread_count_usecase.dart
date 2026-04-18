import '../repositories/messaging_repository.dart';
class GetUnreadMessageCountUseCase {
  final MessagingRepository repo;
  const GetUnreadMessageCountUseCase(this.repo);
  Future<int> call() => repo.getUnreadCount();
}
