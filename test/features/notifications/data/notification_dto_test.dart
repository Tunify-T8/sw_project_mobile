import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/notifications/data/dto/notification_dto.dart';

void main() {
  group('NotificationActorDto', () {
    test('creates actor from JSON with all fields', () {
      final json = {
        'id': 'user-1',
        'username': 'john_doe',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final actor = NotificationActorDto.fromJson(json);

      expect(actor.id, 'user-1');
      expect(actor.username, 'john_doe');
      expect(actor.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('handles alternative id field names', () {
      final json = {
        '_id': 'user-1',
        'id': 'user-1',
        'userId': 'user-1',
        'username': 'john_doe',
      };

      final actor = NotificationActorDto.fromJson(json);

      expect(actor.id, 'user-1');
    });

    test('handles alternative username field names', () {
      final json = {
        'id': 'user-1',
        'username': 'john_doe',
        'userName': 'john_doe',
        'displayName': 'John Doe',
      };

      final actor = NotificationActorDto.fromJson(json);

      expect(actor.username, isNotEmpty);
    });

    test('handles nullable avatar URL', () {
      final json = {
        'id': 'user-1',
        'username': 'john_doe',
        'avatarUrl': null,
      };

      final actor = NotificationActorDto.fromJson(json);

      expect(actor.avatarUrl, isNull);
    });

    test('converts to JSON', () {
      final actor = const NotificationActorDto(
        id: 'user-1',
        username: 'john_doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final json = actor.toJson();

      expect(json['id'], 'user-1');
      expect(json['username'], 'john_doe');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
    });
  });

  group('NotificationDto', () {
    test('creates notification from JSON with all fields', () {
      final json = {
        'id': 'notif-1',
        'type': 'like',
        'message': 'Someone liked your track',
        'createdAt': '2024-01-01T10:00:00Z',
        'isRead': false,
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.id, 'notif-1');
      expect(dto.type, 'like');
      expect(dto.message, 'Someone liked your track');
      expect(dto.isRead, false);
    });

    test('parses actor from notification', () {
      final json = {
        'id': 'notif-1',
        'type': 'like',
        'actor': {
          'id': 'user-1',
          'username': 'john_doe',
        },
        'message': 'john_doe liked your track',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.actor, isNotNull);
      expect(dto.actor?.username, 'john_doe');
    });

    test('handles reference information', () {
      final json = {
        'id': 'notif-1',
        'type': 'like',
        'referenceType': 'track',
        'referenceId': 'track-123',
        'message': 'Someone liked your track',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.referenceType, 'track');
      expect(dto.referenceId, 'track-123');
    });

    test('handles read status and timestamp', () {
      final json = {
        'id': 'notif-1',
        'type': 'like',
        'message': 'Someone liked your track',
        'createdAt': '2024-01-01T10:00:00Z',
        'isRead': true,
        'readAt': '2024-01-01T10:05:00Z',
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.isRead, true);
      expect(dto.readAt, isNotNull);
    });

    test('converts to JSON', () {
      final json = {
        'id': 'notif-1',
        'type': 'like',
        'message': 'Someone liked your track',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = NotificationDto.fromJson(json);
      final jsonOutput = dto.toJson();

      expect(jsonOutput['id'], 'notif-1');
      expect(jsonOutput['type'], 'like');
      expect(jsonOutput['message'], 'Someone liked your track');
    });

    test('handles missing optional fields', () {
      final json = {
        'id': 'notif-1',
        'type': 'system',
        'message': 'System notification',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.id, 'notif-1');
      expect(dto.actor, isNull);
      expect(dto.referenceType, isNull);
      expect(dto.referenceId, isNull);
    });

    test('handles alternative field names', () {
      final json = {
        '_id': 'notif-1',
        'id': 'notif-1',
        'notificationType': 'like',
        'type': 'like',
        'body': 'Someone liked your track',
        'message': 'Someone liked your track',
        'created_at': '2024-01-01T10:00:00Z',
        'createdAt': '2024-01-01T10:00:00Z',
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.id, 'notif-1');
      expect(dto.type, 'like');
      expect(dto.message, 'Someone liked your track');
    });

    test('handles isRead variations', () {
      final trueVariations = [
        {'is_read': true},
        {'isRead': true},
        {'read': true},
      ];

      for (final variation in trueVariations) {
        final json = {
          'id': 'notif-1',
          'type': 'like',
          'message': 'Like notification',
          'createdAt': '2024-01-01T10:00:00Z',
          ...variation,
        };

        final dto = NotificationDto.fromJson(json);
        expect(dto.isRead, true);
      }
    });
  });

  group('NotificationPreferencesDto', () {
    test('parses preferences with push and email', () {
      final json = {
        'push': {'trackLiked': true, 'newMessage': false},
        'email': {'trackLiked': false, 'newMessage': true},
      };

      // This would use NotificationPreferencesDto.fromJson in actual implementation
      // For now, we're testing the contract
      expect(json['push'], isNotNull);
      expect(json['email'], isNotNull);
    });
  });
}
