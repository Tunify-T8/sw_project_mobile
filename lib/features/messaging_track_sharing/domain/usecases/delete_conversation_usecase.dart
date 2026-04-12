import '../repositories/messaging_repository.dart';
class DeleteConversationUseCase {
  final MessagingRepository repo;
  const DeleteConversationUseCase(this.repo);
  Future<void> call(String conversationId) => repo.deleteConversation(conversationId);
}
