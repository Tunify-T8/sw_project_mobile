import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';
import '../dto/user_preview_dto.dart';

/// In-memory dataset powering the mock repository.
///
/// This store is responsible for:
/// - keeping track of the current signed-in mock user
/// - storing user previews used in conversations
/// - storing conversations and message history
/// - hiding archived chats from the Activity screen without deleting them
///
/// Why this file needs [syncCurrentUser]:
/// The provider updates the mock store with the authenticated user from the
/// auth module. Without that method, the provider cannot tell the messaging
/// store who the current user is, and Dart throws:
/// "The method 'syncCurrentUser' isn't defined for the type 'MockMessagingStore'."
class MockMessagingStore {
  /// Cached user previews that may come from profile/search/chat flows.
  final Map<String, UserPreviewDto> users = {};

  /// All conversations keyed by conversationId.
  final Map<String, ConversationDto> conversations = {};

  /// Message history keyed by conversationId.
  final Map<String, List<MessageDto>> messages = {};

  /// Archived conversations should disappear from Activity,
  /// but their messages should remain stored.
  final Set<String> archivedConversationIds = <String>{};

  /// Represents the currently signed-in user in mock mode.
  String currentUserId = 'mock-user-001';

  MockMessagingStore() {
    syncCurrentUser(
      id: currentUserId,
      displayName: 'You',
      avatarUrl: null,
    );
  }

  /// Syncs the mock messaging store with the currently authenticated user.
  ///
  /// This is called from the messaging repository provider.
  /// If the signed-in user changes, we reset in-memory conversation state
  /// so one mock account does not see another mock account's chats.
  void syncCurrentUser({
    required String id,
    required String displayName,
    String? avatarUrl,
  }) {
    final didChangeUser = currentUserId != id;
    currentUserId = id;

    users[id] = UserPreviewDto(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );

    if (didChangeUser) {
      conversations.clear();
      messages.clear();
      archivedConversationIds.clear();
    }

    if (conversations.isEmpty && messages.isEmpty) {
      _seedInitialConversation();
    }
  }

  /// Registers or updates a lightweight preview of a user.
  void registerUserPreview({
    required String id,
    required String displayName,
    String? avatarUrl,
  }) {
    users[id] = UserPreviewDto(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  /// Returns a cached preview if available, otherwise creates one.
  UserPreviewDto previewForUser(
    String userId, {
    String? fallbackDisplayName,
    String? fallbackAvatarUrl,
  }) {
    final existing = users[userId];
    if (existing != null) return existing;

    final preview = UserPreviewDto(
      id: userId,
      displayName: _friendlyDisplayName(
        (fallbackDisplayName?.trim().isNotEmpty ?? false)
            ? fallbackDisplayName!
            : userId,
      ),
      avatarUrl: fallbackAvatarUrl,
    );

    users[userId] = preview;
    return preview;
  }

  /// Builds a stable 1-to-1 conversation id.
  ///
  /// We sort the two ids so:
  /// currentUser:otherUser
  /// and
  /// otherUser:currentUser
  /// do not create two separate chats.
  String conversationIdFor(String otherUserId) {
    return currentUserId.compareTo(otherUserId) < 0
        ? '$currentUserId:$otherUserId'
        : '$otherUserId:$currentUserId';
  }

  /// Given a conversation id, return the id of the other participant.
  String otherUserIdFromConversation(String conversationId) {
    final parts = conversationId.split(':');
    if (parts.length != 2) return conversationId;
    return parts.first == currentUserId ? parts.last : parts.first;
  }

  /// Ensures a conversation and its message list exist.
  void ensureConversationExists(
    String conversationId, {
    required String otherUserId,
    String? fallbackDisplayName,
    String? fallbackAvatarUrl,
  }) {
    conversations.putIfAbsent(
      conversationId,
      () => ConversationDto(
        conversationId: conversationId,
        otherUser: previewForUser(
          otherUserId,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatarUrl: fallbackAvatarUrl,
        ),
        lastMessagePreview: null,
        lastMessageAt: null,
        unreadCount: 0,
        isBlocked: false,
      ),
    );

    messages.putIfAbsent(conversationId, () => <MessageDto>[]);
  }

  /// Seeds an initial mock conversation so the Activity screen is not empty.
  void _seedInitialConversation() {
    final youssef = previewForUser(
      'u_youssef',
      fallbackDisplayName: 'Youssef Muhammed',
    );

    final convoId = conversationIdFor(youssef.id);

    final greeting = MessageDto(
      id: 'm_seed_hii',
      conversationId: convoId,
      senderId: youssef.id,
      type: 'TEXT',
      text: 'hii',
      createdAt: DateTime.now(),
      isRead: false,
    );

    conversations[convoId] = ConversationDto(
      conversationId: convoId,
      otherUser: youssef,
      lastMessagePreview: greeting.text,
      lastMessageAt: greeting.createdAt,
      unreadCount: 1,
      isBlocked: false,
    );

    messages[convoId] = [greeting];
  }

  /// Makes ids like "u_youssef" display more nicely as "Youssef".
  String _friendlyDisplayName(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (cleaned.isEmpty) return raw;

    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}