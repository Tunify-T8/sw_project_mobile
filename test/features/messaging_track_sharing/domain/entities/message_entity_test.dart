import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_entity.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_attachment.dart';

void main() {
  group('MessageEntity', () {
    test('creates message with all required fields', () {
      final now = DateTime.now();
      final message = MessageEntity(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'user-1',
        type: MessageType.text,
        text: 'Hello world',
        createdAt: now,
      );

      expect(message.id, 'msg-1');
      expect(message.conversationId, 'conv-1');
      expect(message.senderId, 'user-1');
      expect(message.type, MessageType.text);
      expect(message.text, 'Hello world');
      expect(message.createdAt, now);
      expect(message.isPending, false);
      expect(message.isFailed, false);
    });

    test('marks message as read when deliveryStatus is read', () {
      final message = MessageEntity(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'user-1',
        type: MessageType.text,
        text: 'Hello',
        createdAt: DateTime.now(),
        deliveryStatus: MessageDeliveryStatus.read,
      );

      expect(message.isRead, true);
    });

    test('preserves isRead=true when explicitly set', () {
      final message = MessageEntity(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'user-1',
        type: MessageType.text,
        text: 'Hello',
        createdAt: DateTime.now(),
        isRead: true,
        deliveryStatus: MessageDeliveryStatus.sent,
      );

      expect(message.isRead, true);
    });

    test('copyWith updates specific fields', () {
      final now = DateTime.now();
      final message = MessageEntity(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'user-1',
        type: MessageType.text,
        text: 'Hello',
        createdAt: now,
        isRead: false,
        deliveryStatus: MessageDeliveryStatus.sent,
      );

      final updated = message.copyWith(
        isRead: true,
        deliveryStatus: MessageDeliveryStatus.read,
      );

      expect(updated.id, 'msg-1');
      expect(updated.conversationId, 'conv-1');
      expect(updated.isRead, true);
      expect(updated.deliveryStatus, MessageDeliveryStatus.read);
    });

    test('copyWith preserves original fields when not specified', () {
      final now = DateTime.now();
      final message = MessageEntity(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'user-1',
        type: MessageType.text,
        text: 'Hello',
        createdAt: now,
        isPending: true,
      );

      final updated = message.copyWith(isPending: false);

      expect(updated.isPending, false);
      expect(updated.isFailed, message.isFailed);
      expect(updated.text, 'Hello');
    });

    test('supports attachment messages', () {
      final attachment = MessageAttachment(
        id: 'track-1',
        type: MessageAttachmentType.track,
        backendKind: MessageAttachmentBackendKind.trackUpload,
        title: 'My Track',
      );

      final message = MessageEntity(
        id: 'msg-2',
        conversationId: 'conv-1',
        senderId: 'user-1',
        type: MessageType.attachment,
        attachments: [attachment],
        createdAt: DateTime.now(),
      );

      expect(message.attachments, hasLength(1));
      expect(message.attachments.first.title, 'My Track');
    });

    test('tracks pending and failed states', () {
      final message = MessageEntity(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'user-1',
        type: MessageType.text,
        text: 'Hello',
        createdAt: DateTime.now(),
        isPending: true,
        isFailed: false,
      );

      final failed = message.copyWith(isPending: false, isFailed: true);

      expect(failed.isPending, false);
      expect(failed.isFailed, true);
    });
  });

  group('MessageDeliveryStatus', () {
    test('has all required statuses', () {
      expect(MessageDeliveryStatus.notDelivered, isNotNull);
      expect(MessageDeliveryStatus.sent, isNotNull);
      expect(MessageDeliveryStatus.delivered, isNotNull);
      expect(MessageDeliveryStatus.read, isNotNull);
    });
  });

  group('MessageType', () {
    test('has text and attachment types', () {
      expect(MessageType.text, isNotNull);
      expect(MessageType.attachment, isNotNull);
    });
  });
}
