import '../repositories/messaging_repository.dart';
class MarkConversationReadUseCase {
  final MessagingRepository repo;
  const MarkConversationReadUseCase(this.repo);
  Future<void> call(String conversationId) => repo.markConversationRead(conversationId);
}
