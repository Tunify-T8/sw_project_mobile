import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/data/dto/message_dto.dart';

void main() {
  group('MessageDto', () {
    test('parses message from minimal JSON', () {
      final json = {
        'id': 'msg-1',
        'conversationId': 'conv-1',
        'senderId': 'user-1',
        'type': 'text',
        'text': 'Hello',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = MessageDto.fromJson(json, fallbackConversationId: 'conv-1');

      expect(dto.id, 'msg-1');
      expect(dto.conversationId, 'conv-1');
      expect(dto.senderId, 'user-1');
      expect(dto.type, 'text');
      expect(dto.text, 'Hello');
    });

    test('handles alternative field names', () {
      final json = {
        '_id': 'msg-1',
        'messageId': 'msg-1',
        'conversation_id': 'conv-1',
        'conversationId': 'conv-1',
        'senderId': 'user-1',
        'type': 'text',
        'message': 'Hello',
        'text': 'Hello',
        'created_at': '2024-01-01T10:00:00Z',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = MessageDto.fromJson(json, fallbackConversationId: 'conv-1');

      expect(dto.id, isNotEmpty);
      expect(dto.senderId, 'user-1');
      expect(dto.text, 'Hello');
    });

    test('falls back to fallbackConversationId when conversationId not provided', () {
      final json = {
        'id': 'msg-1',
        'senderId': 'user-1',
        'type': 'text',
        'text': 'Hello',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = MessageDto.fromJson(json, fallbackConversationId: 'conv-fallback');

      expect(dto.conversationId, 'conv-fallback');
    });

    test('parses isRead flag correctly', () {
      final readJson = {
        'id': 'msg-1',
        'conversationId': 'conv-1',
        'senderId': 'user-1',
        'type': 'text',
        'text': 'Hello',
        'isRead': true,
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final unreadJson = {
        'id': 'msg-1',
        'conversationId': 'conv-1',
        'senderId': 'user-1',
        'type': 'text',
        'text': 'Hello',
        'isRead': false,
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final readDto = MessageDto.fromJson(readJson, fallbackConversationId: 'conv-1');
      final unreadDto = MessageDto.fromJson(unreadJson, fallbackConversationId: 'conv-1');

      expect(readDto.isRead, true);
      expect(unreadDto.isRead, false);
    });

    test('converts to JSON', () {
      final json = {
        'id': 'msg-1',
        'conversationId': 'conv-1',
        'senderId': 'user-1',
        'type': 'text',
        'text': 'Hello',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = MessageDto.fromJson(json, fallbackConversationId: 'conv-1');
      final jsonOutput = dto.toJson();

      expect(jsonOutput['id'], 'msg-1');
      expect(jsonOutput['conversationId'], 'conv-1');
      expect(jsonOutput['senderId'], 'user-1');
      expect(jsonOutput['type'], 'text');
      expect(jsonOutput['text'], 'Hello');
    });

    test('handles missing text gracefully', () {
      final json = {
        'id': 'msg-1',
        'conversationId': 'conv-1',
        'senderId': 'user-1',
        'type': 'attachment',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = MessageDto.fromJson(json, fallbackConversationId: 'conv-1');

      expect(dto.id, 'msg-1');
      expect(dto.type, 'attachment');
    });
  });
}
