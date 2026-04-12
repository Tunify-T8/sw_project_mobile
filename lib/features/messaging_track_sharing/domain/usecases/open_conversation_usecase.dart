import '../repositories/messaging_repository.dart';
/// Creates a conversation with [otherUserId] or returns the existing one.
class OpenConversationUseCase {
  final MessagingRepository repo;
  const OpenConversationUseCase(this.repo);
  Future<String> call(String otherUserId) => repo.createOrGetConversation(otherUserId);
}
