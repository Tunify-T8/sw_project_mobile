import '../repositories/messaging_repository.dart';

/// Creates a conversation with [otherUserId] or returns the existing one.
/// If the conversation was archived, it is unarchived so it reappears in the list.
class OpenConversationUseCase {
  final MessagingRepository repo;
  const OpenConversationUseCase(this.repo);

  Future<String> call(String otherUserId) async {
    return repo.createOrGetConversation(otherUserId);
  }
}
