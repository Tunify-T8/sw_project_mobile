import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/data/dto/social_user_dto.dart';

void main() {
  group('SocialUserDTO.fromJson', () {
    test('maps all fields correctly when full JSON is provided', () {
      final dto = SocialUserDTO.fromJson({
        'id': '42',
        'username': 'sound_user',
        'avatarUrl': 'https://example.com/avatar.png',
        'coverUrl': 'https://example.com/cover.png',
        'userType': 'ARTIST',
        'location': 'Cairo',
        'followersCount': 120,
        'followingCount': 55,
        'tracksUploadedCount': 19,
        'mutualFollowersCount': 7,
        'isVerified': true,
        'isFollowing': true,
        'isNotificationEnabled': true,
        'isBlocked': true,
      });

      expect(dto.id, '42');
      expect(dto.username, 'sound_user');
      expect(dto.avatarUrl, 'https://example.com/avatar.png');
      expect(dto.coverUrl, 'https://example.com/cover.png');
      expect(dto.userType, 'ARTIST');
      expect(dto.location, 'Cairo');
      expect(dto.followersCount, 120);
      expect(dto.followingCount, 55);
      expect(dto.tracksUploadedCount, 19);
      expect(dto.mutualFollowersCount, 7);
      expect(dto.isVerified, isTrue);
      expect(dto.isFollowing, isTrue);
      expect(dto.isNotificationEnabled, isTrue);
      expect(dto.isBlocked, isTrue);
    });

    test('falls back to empty string for missing null id', () {
      final missingId = SocialUserDTO.fromJson({
        'username': 'listener',
      });
      final nullId = SocialUserDTO.fromJson({
        'id': null,
        'username': 'listener',
      });

      expect(missingId.id, '');
      expect(nullId.id, '');
    });

    test('falls back to empty string for missing null username', () {
      final missingUsername = SocialUserDTO.fromJson({
        'id': '1',
      });
      final nullUsername = SocialUserDTO.fromJson({
        'id': '1',
        'username': null,
      });

      expect(missingUsername.username, '');
      expect(nullUsername.username, '');
    });

    test('keeps nullable string fields as null when absent', () {
      final dto = SocialUserDTO.fromJson({
        'id': '1',
        'username': 'artist',
      });

      expect(dto.avatarUrl, isNull);
      expect(dto.coverUrl, isNull);
      expect(dto.userType, isNull);
      expect(dto.location, isNull);
    });

    test(
      'uses false defaults for flags when isVerified isFollowing isNotificationEnabled and isBlocked are absent',
      () {
        final dto = SocialUserDTO.fromJson({
          'id': '1',
          'username': 'artist',
        });

        expect(dto.isVerified, isFalse);
        expect(dto.isFollowing, isFalse);
        expect(dto.isNotificationEnabled, isFalse);
        expect(dto.isBlocked, isFalse);
      },
    );

    test('converts id and username to string using toString', () {
      final dto = SocialUserDTO.fromJson({
        'id': 123,
        'username': 456,
      });

      expect(dto.id, '123');
      expect(dto.username, '456');
    });
  });
}
