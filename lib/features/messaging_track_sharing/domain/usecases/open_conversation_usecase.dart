import '../repositories/messaging_repository.dart';

/// Creates a conversation with [otherUserId] or returns the existing one.
/// If the conversation was archived, it is unarchived so it reappears in the list.
class OpenConversationUseCase {
  final MessagingRepository repo;
  const OpenConversationUseCase(this.repo);

  Future<String> call(String otherUserId) async {
    final conversationId = await repo.createOrGetConversation(otherUserId);
    if (conversationId.isNotEmpty) {
      await repo.unarchiveConversation(conversationId);
    }
    return conversationId;
  }
}
