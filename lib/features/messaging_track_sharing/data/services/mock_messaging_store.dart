import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/user_preview_dto.dart';

/// In-memory dataset powering the mock repository.
///
/// Seeded with a single conversation with "Youssef Muhammed" so the messaging
/// UI has something to render on first launch — the user can take it from
/// there by sending replies, which the mock socket echoes back as new
/// incoming messages after a short delay.
class MockMessagingStore {
  final Map<String, ConversationDto> conversations = {};
  final Map<String, List<MessageDto>> messages = {};
  String currentUserId = 'me';

  MockMessagingStore() {
    const youssef = UserPreviewDto(
      id: 'u_youssef',
      displayName: 'Youssef Muhammed',
      avatarUrl: null,
    );
    const convoId = 'me:u_youssef';

    final hii = MessageDto(
      id: 'm_seed_hii',
      conversationId: convoId,
      senderId: youssef.id,
      type: 'TEXT',
      text: 'hii',
      // Use "now" so the relative timestamp on the list tile reads as fresh
      // when the user first opens the app. The chat screen will format it
      // as h:mm AM/PM, matching SoundCloud.
      createdAt: DateTime.now(),
      isRead: false,
    );

    conversations[convoId] = ConversationDto(
      conversationId: convoId,
      otherUser: youssef,
      lastMessagePreview: hii.text,
      lastMessageAt: hii.createdAt,
      unreadCount: 1,
    );

    messages[convoId] = [hii];
  }
}
