import '../repositories/messaging_repository.dart';

class ArchiveConversationUseCase {
  final MessagingRepository repo;
  const ArchiveConversationUseCase(this.repo);
  Future<void> call(String conversationId) => repo.archiveConversation(conversationId);
}
