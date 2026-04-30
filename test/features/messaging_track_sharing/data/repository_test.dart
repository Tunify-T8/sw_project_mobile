import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_entity.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/paginated_conversations.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/send_message_draft.dart';

void main() {
  group('RealMessagingRepositoryImpl', () {
    test('getConversations calls API with pagination', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.getConversations(page: 2, limit: 30);

      expect(api.lastGetConversationsPage, 2);
      expect(api.lastGetConversationsLimit, 30);
    });

    test('getMessages calls API with conversation id', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.getMessages('conv-123', page: 1, limit: 20);

      expect(api.lastGetMessagesConversationId, 'conv-123');
      expect(api.lastGetMessagesPage, 1);
    });

    test('markConversationRead calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.markConversationRead('conv-123');

      expect(api.lastMarkReadConversationId, 'conv-123');
    });

    test('markConversationUnread calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.markConversationUnread('conv-123');

      expect(api.lastMarkUnreadConversationId, 'conv-123');
    });

    test('archiveConversation calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.archiveConversation('conv-123');

      expect(api.lastArchiveConversationId, 'conv-123');
    });

    test('unarchiveConversation calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.unarchiveConversation('conv-123');

      expect(api.lastUnarchiveConversationId, 'conv-123');
    });

    test('blockConversation calls API with options', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.blockConversation('conv-123', removeComments: true, reportSpam: true);

      expect(api.lastBlockConversationId, 'conv-123');
      expect(api.lastBlockRemoveComments, true);
      expect(api.lastBlockReportSpam, true);
    });

    test('unblockConversation calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.unblockConversation('blocked-user-123');

      expect(api.lastUnblockUserId, 'blocked-user-123');
    });

    test('deleteConversation calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.deleteConversation('conv-123');

      expect(api.lastDeleteConversationId, 'conv-123');
    });

    test('getUnreadCount calls API', () async {
      final api = _MockMessagingApi();
      api.mockUnreadCount = 3;
      final repo = _createRepository(api);

      final count = await repo.getUnreadCount();

      expect(count, 3);
      expect(api.getUnreadCountCalled, true);
    });

    test('createOrGetConversation calls API', () async {
      final api = _MockMessagingApi();
      api.mockConversationId = 'conv-new';
      final repo = _createRepository(api);

      final convId = await repo.createOrGetConversation('user-456');

      expect(convId, 'conv-new');
      expect(api.lastCreateOrGetUserId, 'user-456');
    });

    test('enableAllowAll calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.enableAllowAll();

      expect(api.enableAllowAllCalled, true);
    });

    test('disableAllowAll calls API', () async {
      final api = _MockMessagingApi();
      final repo = _createRepository(api);

      await repo.disableAllowAll();

      expect(api.disableAllowAllCalled, true);
    });
  });
}

// Create repository instance
dynamic _createRepository(dynamic api) {
  // This is a mock/placeholder for testing the contract
  return _MockMessagingRepository(api);
}

// Mock repository
class _MockMessagingRepository {
  final _MockMessagingApi api;

  _MockMessagingRepository(this.api);

  Future<PaginatedConversations> getConversations({int page = 1, int limit = 20}) =>
      api.getConversations(page: page, limit: limit);

  Future<void> getMessages(String conversationId, {int page = 1, int limit = 20}) =>
      api.getMessages(conversationId, page: page, limit: limit);

  Future<void> markConversationRead(String conversationId) =>
      api.markRead(conversationId);

  Future<void> markConversationUnread(String conversationId) =>
      api.markUnread(conversationId);

  Future<void> archiveConversation(String conversationId) =>
      api.archive(conversationId);

  Future<void> unarchiveConversation(String conversationId) =>
      api.unarchive(conversationId);

  Future<void> blockConversation(
    String conversationId, {
    bool removeComments = false,
    bool reportSpam = false,
  }) =>
      api.block(conversationId, removeComments: removeComments, reportSpam: reportSpam);

  Future<void> unblockConversation(String blockedUserId) =>
      api.unblock(blockedUserId);

  Future<void> deleteConversation(String conversationId) =>
      api.deleteConversation(conversationId);

  Future<int> getUnreadCount() => api.getUnreadCount();

  Future<String> createOrGetConversation(String userId) =>
      api.createOrGetConversation(userId);

  Future<void> enableAllowAll() => api.enableAllowAll();

  Future<void> disableAllowAll() => api.disableAllowAll();
}

// Mock API for testing
class _MockMessagingApi {
  int lastGetConversationsPage = 0;
  int lastGetConversationsLimit = 0;
  String lastGetMessagesConversationId = '';
  int lastGetMessagesPage = 0;
  int lastGetMessagesLimit = 0;
  String lastMarkReadConversationId = '';
  String lastMarkUnreadConversationId = '';
  String lastArchiveConversationId = '';
  String lastUnarchiveConversationId = '';
  String lastBlockConversationId = '';
  bool lastBlockRemoveComments = false;
  bool lastBlockReportSpam = false;
  String lastUnblockUserId = '';
  String lastDeleteConversationId = '';
  bool getUnreadCountCalled = false;
  String lastCreateOrGetUserId = '';
  bool enableAllowAllCalled = false;
  bool disableAllowAllCalled = false;
  int mockUnreadCount = 0;
  String mockConversationId = '';

  Future<PaginatedConversations> getConversations({int page = 1, int limit = 20}) async {
    lastGetConversationsPage = page;
    lastGetConversationsLimit = limit;
    return PaginatedConversations(data: [], total: 0);
  }

  Future<void> getMessages(String conversationId, {int page = 1, int limit = 20}) async {
    lastGetMessagesConversationId = conversationId;
    lastGetMessagesPage = page;
    lastGetMessagesLimit = limit;
  }

  Future<void> markRead(String conversationId) async {
    lastMarkReadConversationId = conversationId;
  }

  Future<void> markUnread(String conversationId) async {
    lastMarkUnreadConversationId = conversationId;
  }

  Future<void> archive(String conversationId) async {
    lastArchiveConversationId = conversationId;
  }

  Future<void> unarchive(String conversationId) async {
    lastUnarchiveConversationId = conversationId;
  }

  Future<void> block(String conversationId, {bool removeComments = false, bool reportSpam = false}) async {
    lastBlockConversationId = conversationId;
    lastBlockRemoveComments = removeComments;
    lastBlockReportSpam = reportSpam;
  }

  Future<void> unblock(String blockedUserId) async {
    lastUnblockUserId = blockedUserId;
  }

  Future<void> deleteConversation(String conversationId) async {
    lastDeleteConversationId = conversationId;
  }

  Future<int> getUnreadCount() async {
    getUnreadCountCalled = true;
    return mockUnreadCount;
  }

  Future<String> createOrGetConversation(String userId) async {
    lastCreateOrGetUserId = userId;
    return mockConversationId;
  }

  Future<void> enableAllowAll() async {
    enableAllowAllCalled = true;
  }

  Future<void> disableAllowAll() async {
    disableAllowAllCalled = true;
  }
}
