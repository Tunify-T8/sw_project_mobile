import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/paginated_conversations.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/conversation_entity.dart';
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
      expect(result.data, isNotEmpty);
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
      final useCase = GetUnreadCountUseCase(repository);

      final count = await useCase();

      expect(count, 5);
      expect(repository.getUnreadCountCalled, true);
    });

    test('returns zero when no unread messages', () async {
      final repository = _MockMessagingRepository();
      repository.unreadCount = 0;
      final useCase = GetUnreadCountUseCase(repository);

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
      data: [
        ConversationEntity(
          id: 'conv-1',
          otherUser: const UserPreview(
            id: 'user-1',
            username: 'john_doe',
          ),
        ),
      ],
      total: 1,
    );
  }

  @override
  Future<PaginatedConversations> searchConversations(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    return PaginatedConversations(data: [], total: 0);
  }

  @override
  Future<void> deleteConversation(String id) async {}

  @override
  Future<void> archiveConversation(String id) async {}

  @override
  Future<void> unarchiveConversation(String id) async {}

  @override
  Future<void> blockConversation(
    String id, {
    bool removeComments = false,
    bool reportSpam = false,
  }) async {}

  @override
  Stream<List<dynamic>> watchRealtimeEvents() => const Stream.empty();

  @override
  Future<void> sendMessage(String conversationId, dynamic draft) async {}

  @override
  Future<int> getUnreadCount() async {
    getUnreadCountCalled = true;
    return unreadCount;
  }

  @override
  Future<PaginatedConversations> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    lastGetMessagesConversationId = conversationId;
    lastGetMessagesPage = page;
    lastGetMessagesLimit = limit;

    return PaginatedConversations(data: [], total: 0);
  }

  @override
  Future<void> markConversationRead(String conversationId) async {}

  @override
  Future<void> markConversationUnread(String conversationId) async {}

  @override
  Future<void> unblockConversation(String blockedUserId) async {}

  @override
  Future<void> enableAllowAll() async {}

  @override
  Future<void> disableAllowAll() async {}

  @override
  Future<String> createOrGetConversation(String userId) async => 'conv-new';
}
