import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/paginated_conversations.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/paginated_messages.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/conversation_entity.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_entity.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/realtime_event.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/send_message_draft.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/user_preview.dart';
import 'package:software_project/features/messaging_track_sharing/domain/usecases/get_conversations_usecase.dart';
import 'package:software_project/features/messaging_track_sharing/domain/usecases/get_messages_usecase.dart';
import 'package:software_project/features/messaging_track_sharing/domain/usecases/get_unread_count_usecase.dart';
import 'package:software_project/features/messaging_track_sharing/domain/repositories/messaging_repository.dart';

void main() {
  group('GetConversationsUseCase', () {
    test('calls repository with default parameters', () async {
      final repository = _MockMessagingRepository();
      final useCase = GetConversationsUseCase(repository);

      await useCase();

      expect(repository.lastGetConversationsPage, 1);
      expect(repository.lastGetConversationsLimit, 20);
    });

    test('calls repository with custom parameters', () async {
      final repository = _MockMessagingRepository();
      final useCase = GetConversationsUseCase(repository);

      await useCase(page: 3, limit: 50);

      expect(repository.lastGetConversationsPage, 3);
      expect(repository.lastGetConversationsLimit, 50);
    });

    test('returns paginated conversations from repository', () async {
      final repository = _MockMessagingRepository();
      final useCase = GetConversationsUseCase(repository);

      final result = await useCase();

      expect(result, isA<PaginatedConversations>());
      expect(result.items, isNotEmpty);
    });
  });

  group('GetMessagesUseCase', () {
    test('calls repository with conversation id', () async {
      final repository = _MockMessagingRepository();
      final useCase = GetMessagesUseCase(repository);

      await useCase('conv-123');

      expect(repository.lastGetMessagesConversationId, 'conv-123');
      expect(repository.lastGetMessagesPage, 1);
      expect(repository.lastGetMessagesLimit, 20);
    });

    test('calls repository with custom pagination', () async {
      final repository = _MockMessagingRepository();
      final useCase = GetMessagesUseCase(repository);

      await useCase('conv-123', page: 2, limit: 30);

      expect(repository.lastGetMessagesConversationId, 'conv-123');
      expect(repository.lastGetMessagesPage, 2);
      expect(repository.lastGetMessagesLimit, 30);
    });
  });

  group('GetUnreadCountUseCase', () {
    test('calls repository to get unread count', () async {
      final repository = _MockMessagingRepository();
      repository.unreadCount = 5;
      final useCase = GetUnreadMessageCountUseCase(repository);

      final count = await useCase();

      expect(count, 5);
      expect(repository.getUnreadCountCalled, true);
    });

    test('returns zero when no unread messages', () async {
      final repository = _MockMessagingRepository();
      repository.unreadCount = 0;
      final useCase = GetUnreadMessageCountUseCase(repository);

      final count = await useCase();

      expect(count, 0);
    });
  });
}

// Mock repository for testing use cases
class _MockMessagingRepository implements MessagingRepository {
  int lastGetConversationsPage = 0;
  int lastGetConversationsLimit = 0;
  String lastGetMessagesConversationId = '';
  int lastGetMessagesPage = 0;
  int lastGetMessagesLimit = 0;
  bool getUnreadCountCalled = false;
  int unreadCount = 0;

  @override
  Future<PaginatedConversations> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    lastGetConversationsPage = page;
    lastGetConversationsLimit = limit;

    return PaginatedConversations(
      items: [
        ConversationEntity(
          conversationId: 'conv-1',
          otherUser: const UserPreview(
            id: 'user-1',
            displayName: 'john_doe',
          ),
        ),
      ],
      page: page,
      limit: limit,
      total: 1,
    );
  }

  @override
  Future<void> deleteConversation(String id) async {}

  @override
  Future<void> archiveConversation(String id) async {}

  @override
  Future<void> unarchiveConversation(String id) async {}

  @override
  Future<void> blockConversation(String id) async {}

  @override
  Future<MessageEntity> sendMessage(
    String conversationId,
    SendMessageDraft draft,
  ) async =>
      MessageEntity(
        id: 'msg-1',
        conversationId: conversationId,
        senderId: 'user-1',
        type: draft.type,
        createdAt: DateTime.now(),
        text: draft.text,
      );

  @override
  Future<int> getUnreadCount() async {
    getUnreadCountCalled = true;
    return unreadCount;
  }

  @override
  Future<PaginatedMessages> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    lastGetMessagesConversationId = conversationId;
    lastGetMessagesPage = page;
    lastGetMessagesLimit = limit;

    return PaginatedMessages(items: const [], page: page, limit: limit, total: 0);
  }

  @override
  Future<void> markConversationRead(String conversationId) async {}

  @override
  Future<void> enableReceiveFromAnyone() async {}

  @override
  Future<void> disableReceiveFromAnyone() async {}

  @override
  Future<void> joinConversation(String conversationId) async {}

  @override
  Future<void> leaveConversation(String conversationId) async {}

  @override
  Future<void> markMessageDelivered({
    required String conversationId,
    required String messageId,
  }) async {}

  @override
  Future<void> markMessageRead({
    required String conversationId,
    required String messageId,
  }) async {}

  @override
  void startTyping(String conversationId) {}

  @override
  void stopTyping(String conversationId) {}

  @override
  Stream<RealtimeMessagingEvent> realtimeEvents() => const Stream.empty();

  @override
  Future<void> connectRealtime() async {}

  @override
  Future<void> disconnectRealtime() async {}

  @override
  Future<String> createOrGetConversation(String userId) async => 'conv-new';
}
