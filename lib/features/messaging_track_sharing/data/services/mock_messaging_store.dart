import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/user_preview_dto.dart';

/// In-memory dataset powering the mock repository.
class MockMessagingStore {
  final Map<String, ConversationDto> conversations = {};
  final Map<String, List<MessageDto>> messages = {};
  String currentUserId = 'me';
  MockMessagingStore() {
    const alice = UserPreviewDto(id: 'u1', displayName: 'Alice', avatarUrl: null);
    const convoId = 'me:u1';
    conversations[convoId] = ConversationDto(
      conversationId: convoId, otherUser: alice,
      lastMessagePreview: 'hey!', lastMessageAt: null, unreadCount: 1,
    );
    messages[convoId] = [
      MessageDto(id: 'm1', conversationId: convoId, senderId: 'u1',
        type: 'TEXT', text: 'hey!', createdAt: DateTime.now()),
    ];
  }
}
