import '../repositories/messaging_repository.dart';
class BlockConversationUseCase {
  final MessagingRepository repo;
  const BlockConversationUseCase(this.repo);
  Future<void> call(String conversationId) => repo.blockConversation(conversationId);
}
