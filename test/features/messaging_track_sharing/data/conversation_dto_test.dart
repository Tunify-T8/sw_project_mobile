import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/data/dto/conversation_dto.dart';

void main() {
  group('ConversationDto', () {
    test('keeps the last message sender from nested sender data', () {
      final dto = ConversationDto.fromJson({
        'id': 'conversation-1',
        'user1Id': 'youssef',
        'user2Id': 'joe',
        'lastMessage': {
          'id': 'message-1',
          'conversationId': 'conversation-1',
          'sender': {'id': 'joe', 'username': 'Joe'},
          'type': 'TEXT',
          'text': 'hii',
          'createdAt': '2026-04-30T10:00:00Z',
        },
        'unreadCount': 1,
      }, currentUserId: 'youssef');

      expect(dto.lastMessageSenderId, 'joe');
    });

    test('accepts backend aliases for last message sender id', () {
      final dto = ConversationDto.fromJson({
        'id': 'conversation-1',
        'user1Id': 'youssef',
        'user2Id': 'joe',
        'last_sender_id': 'youssef',
        'last_message_preview': 'hii',
        'unread_count': 1,
      }, currentUserId: 'youssef');

      expect(dto.lastMessageSenderId, 'youssef');
    });
  });
}
