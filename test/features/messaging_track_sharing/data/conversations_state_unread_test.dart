import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/conversation_entity.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/user_preview.dart';
import 'package:software_project/features/messaging_track_sharing/presentation/state/conversations_controller.dart';
import 'package:software_project/features/messaging_track_sharing/presentation/state/messages_filter.dart';

void main() {
  group('ConversationsState unread rendering', () {
    test(
      'ignores unread counts when the last message is from current user',
      () {
        final state = ConversationsState(
          items: [
            _conversation(
              id: 'sent-by-me',
              lastMessageSenderId: 'youssef',
              unreadCount: 3,
            ),
            _conversation(
              id: 'sent-by-joe',
              lastMessageSenderId: 'joe',
              unreadCount: 2,
            ),
          ],
        );

        expect(state.hasUnreadForUser(state.items[0], 'youssef'), isFalse);
        expect(state.hasUnreadForUser(state.items[1], 'youssef'), isTrue);
        expect(state.totalUnreadFor('youssef'), 2);
      },
    );

    test('unread filter keeps only incoming unread conversations', () {
      final state = ConversationsState(
        filter: MessagesFilter.unreadOnly,
        items: [
          _conversation(
            id: 'sent-by-me',
            lastMessageSenderId: 'youssef',
            unreadCount: 1,
          ),
          _conversation(
            id: 'sent-by-joe',
            lastMessageSenderId: 'joe',
            unreadCount: 1,
          ),
          _conversation(id: 'already-read', lastMessageSenderId: 'joe'),
        ],
      );

      expect(state.visibleFor('youssef').map((c) => c.conversationId), [
        'sent-by-joe',
      ]);
    });
  });
}

ConversationEntity _conversation({
  required String id,
  String? lastMessageSenderId,
  int unreadCount = 0,
}) {
  return ConversationEntity(
    conversationId: id,
    otherUser: const UserPreview(id: 'joe', displayName: 'Joe'),
    lastMessagePreview: 'hii',
    lastMessageAt: DateTime.utc(2026, 4, 30, 10),
    lastMessageSenderId: lastMessageSenderId,
    unreadCount: unreadCount,
  );
}
