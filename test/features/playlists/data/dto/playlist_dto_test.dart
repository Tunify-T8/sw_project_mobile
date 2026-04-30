import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playlists/data/dto/playlist_dto.dart';
import 'package:software_project/features/playlists/data/dto/playlist_summary_dto.dart';
import 'package:software_project/features/playlists/data/dto/playlist_track_dto.dart';
import 'package:software_project/features/playlists/domain/entities/collection_privacy.dart';
import 'package:software_project/features/playlists/domain/entities/collection_type.dart';

void main() {
  group('PlaylistDto.fromJson', () {
    final baseJson = {
      'id': 'playlist-1',
      'title': 'My Playlist',
      'type': 'PLAYLIST',
      'privacy': 'public',
      'trackCount': 5,
      'likeCount': 12,
      'repostsCount': 3,
      'ownerFollowerCount': 100,
      'isLiked': false,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    };

    test('parses all standard fields', () {
      final dto = PlaylistDto.fromJson(baseJson);

      expect(dto.id, 'playlist-1');
      expect(dto.title, 'My Playlist');
      expect(dto.type, 'PLAYLIST');
      expect(dto.privacy, 'public');
      expect(dto.trackCount, 5);
      expect(dto.likeCount, 12);
      expect(dto.repostsCount, 3);
      expect(dto.ownerFollowerCount, 100);
      expect(dto.isLiked, isFalse);
    });

    test('defaults numeric fields to 0 when absent', () {
      final dto = PlaylistDto.fromJson({
        'id': 'p-2',
        'title': 'Empty Counts',
        'type': 'PLAYLIST',
        'privacy': 'public',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      });

      expect(dto.trackCount, 0);
      expect(dto.likeCount, 0);
      expect(dto.repostsCount, 0);
      expect(dto.ownerFollowerCount, 0);
    });

    test('defaults isLiked to false when absent', () {
      final dto = PlaylistDto.fromJson({
        ...baseJson,
      }..remove('isLiked'));

      expect(dto.isLiked, isFalse);
    });

    test('parses optional description', () {
      final dto = PlaylistDto.fromJson({
        ...baseJson,
        'description': 'A cool playlist',
      });

      expect(dto.description, 'A cool playlist');
    });

    test('description is null when absent', () {
      final dto = PlaylistDto.fromJson(baseJson);

      expect(dto.description, isNull);
    });

    test('parses optional secretToken', () {
      final dto = PlaylistDto.fromJson({
        ...baseJson,
        'secretToken': 'abc123token',
      });

      expect(dto.secretToken, 'abc123token');
    });

    test('secretToken is null when absent', () {
      final dto = PlaylistDto.fromJson(baseJson);

      expect(dto.secretToken, isNull);
    });

    test('parses nested owner object', () {
      final dto = PlaylistDto.fromJson({
        ...baseJson,
        'owner': {
          'id': 'user-1',
          'username': 'artist',
          'displayName': 'DJ Artist',
          'followerCount': 500,
        },
      });

      expect(dto.owner, isNotNull);
      expect(dto.owner!.id, 'user-1');
      expect(dto.owner!.username, 'artist');
      expect(dto.owner!.displayName, 'DJ Artist');
      expect(dto.owner!.followerCount, 500);
    });

    test('owner is null when absent', () {
      final dto = PlaylistDto.fromJson(baseJson);

      expect(dto.owner, isNull);
    });

    test('isLiked is true when set', () {
      final dto = PlaylistDto.fromJson({...baseJson, 'isLiked': true});

      expect(dto.isLiked, isTrue);
    });
  });

  group('PlaylistOwnerDto.fromJson', () {
    test('parses required fields', () {
      final dto = PlaylistOwnerDto.fromJson({
        'id': 'user-1',
        'username': 'testuser',
        'followerCount': 200,
      });

      expect(dto.id, 'user-1');
      expect(dto.username, 'testuser');
      expect(dto.followerCount, 200);
    });

    test('defaults followerCount to 0 when absent', () {
      final dto = PlaylistOwnerDto.fromJson({
        'id': 'user-2',
        'username': 'nocount',
      });

      expect(dto.followerCount, 0);
    });

    test('parses optional displayName and avatarUrl', () {
      final dto = PlaylistOwnerDto.fromJson({
        'id': 'user-3',
        'username': 'artist',
        'displayName': 'The Artist',
        'avatarUrl': 'https://cdn.example.com/avatar.jpg',
        'followerCount': 10,
      });

      expect(dto.displayName, 'The Artist');
      expect(dto.avatarUrl, 'https://cdn.example.com/avatar.jpg');
    });

    test('displayName and avatarUrl are null when absent', () {
      final dto = PlaylistOwnerDto.fromJson({
        'id': 'user-4',
        'username': 'minimal',
        'followerCount': 0,
      });

      expect(dto.displayName, isNull);
      expect(dto.avatarUrl, isNull);
    });
  });

  group('PlaylistSummaryDto.fromJson', () {
    final baseSummaryJson = {
      'id': 'summary-1',
      'title': 'Summary Playlist',
      'type': 'PLAYLIST',
      'privacy': 'public',
      'trackCount': 4,
      'likeCount': 7,
      'repostsCount': 1,
      'ownerFollowerCount': 50,
      'isMine': true,
      'isLiked': false,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    };

    test('parses all standard fields', () {
      final dto = PlaylistSummaryDto.fromJson(baseSummaryJson);

      expect(dto.id, 'summary-1');
      expect(dto.title, 'Summary Playlist');
      expect(dto.type, 'PLAYLIST');
      expect(dto.privacy, 'public');
      expect(dto.trackCount, 4);
      expect(dto.likeCount, 7);
      expect(dto.repostsCount, 1);
      expect(dto.ownerFollowerCount, 50);
      expect(dto.isMine, isTrue);
      expect(dto.isLiked, isFalse);
    });

    test('defaults to empty strings and zeros when fields are absent', () {
      final dto = PlaylistSummaryDto.fromJson({});

      expect(dto.id, '');
      expect(dto.title, '');
      expect(dto.type, 'playlist');
      expect(dto.privacy, 'public');
      expect(dto.trackCount, 0);
      expect(dto.likeCount, 0);
      expect(dto.repostsCount, 0);
      expect(dto.ownerFollowerCount, 0);
      expect(dto.isMine, isFalse);
      expect(dto.isLiked, isFalse);
    });

    test('parses isMine correctly', () {
      final mine = PlaylistSummaryDto.fromJson({...baseSummaryJson, 'isMine': true});
      final notMine = PlaylistSummaryDto.fromJson({...baseSummaryJson, 'isMine': false});

      expect(mine.isMine, isTrue);
      expect(notMine.isMine, isFalse);
    });

    test('description is null when absent', () {
      final dto = PlaylistSummaryDto.fromJson(baseSummaryJson);

      expect(dto.description, isNull);
    });

    test('coverUrl is null when absent', () {
      final dto = PlaylistSummaryDto.fromJson(baseSummaryJson);

      expect(dto.coverUrl, isNull);
    });
  });

  group('PlaylistTrackDto.fromJson', () {
    Map<String, dynamic> buildTrackJson({
      int position = 1,
      String trackId = 'track-1',
      String title = 'Test Song',
      int duration = 200,
      bool isPublic = true,
      int playCount = 50,
      String ownerId = 'user-1',
      String ownerUsername = 'artist',
    }) =>
        {
          'position': position,
          'addedAt': '2026-01-01T00:00:00.000Z',
          'track': {
            'id': trackId,
            'title': title,
            'durationSeconds': duration,
            'isPublic': isPublic,
            'playCount': playCount,
            'user': {
              'id': ownerId,
              'username': ownerUsername,
            },
          },
        };

    test('parses all required fields', () {
      final dto = PlaylistTrackDto.fromJson(buildTrackJson());

      expect(dto.position, 1);
      expect(dto.trackId, 'track-1');
      expect(dto.title, 'Test Song');
      expect(dto.durationSeconds, 200);
      expect(dto.isPublic, isTrue);
      expect(dto.playCount, 50);
      expect(dto.ownerId, 'user-1');
      expect(dto.ownerUsername, 'artist');
    });

    test('defaults playCount to 0 when absent', () {
      final json = buildTrackJson();
      (json['track'] as Map<String, dynamic>).remove('playCount');
      final dto = PlaylistTrackDto.fromJson(json);

      expect(dto.playCount, 0);
    });

    test('parses optional coverUrl from track', () {
      final json = buildTrackJson();
      (json['track'] as Map<String, dynamic>)['coverUrl'] =
          'https://cdn.example.com/cover.jpg';
      final dto = PlaylistTrackDto.fromJson(json);

      expect(dto.coverUrl, 'https://cdn.example.com/cover.jpg');
    });

    test('coverUrl is null when absent', () {
      final dto = PlaylistTrackDto.fromJson(buildTrackJson());

      expect(dto.coverUrl, isNull);
    });

    test('parses optional ownerDisplayName', () {
      final json = buildTrackJson();
      (json['track'] as Map<String, dynamic>)['user']
          ['displayName'] = 'The Artist';
      final dto = PlaylistTrackDto.fromJson(json);

      expect(dto.ownerDisplayName, 'The Artist');
    });

    test('ownerDisplayName is null when absent', () {
      final dto = PlaylistTrackDto.fromJson(buildTrackJson());

      expect(dto.ownerDisplayName, isNull);
    });

    test('parses correct position for multiple tracks', () {
      final dto = PlaylistTrackDto.fromJson(buildTrackJson(position: 3));

      expect(dto.position, 3);
    });
  });

  group('CollectionType.fromJson', () {
    test('parses ALBUM (uppercase)', () {
      expect(CollectionType.fromJson('ALBUM'), CollectionType.album);
    });

    test('parses album (lowercase)', () {
      expect(CollectionType.fromJson('album'), CollectionType.album);
    });

    test('defaults to playlist for PLAYLIST', () {
      expect(CollectionType.fromJson('PLAYLIST'), CollectionType.playlist);
    });

    test('defaults to playlist for unknown value', () {
      expect(CollectionType.fromJson('unknown'), CollectionType.playlist);
    });

    test('toJson returns uppercase string', () {
      expect(CollectionType.playlist.toJson(), 'PLAYLIST');
      expect(CollectionType.album.toJson(), 'ALBUM');
    });
  });

  group('CollectionPrivacy.fromJson', () {
    test('parses private (lowercase)', () {
      expect(CollectionPrivacy.fromJson('private'), CollectionPrivacy.private);
    });

    test('parses PRIVATE (uppercase)', () {
      expect(CollectionPrivacy.fromJson('PRIVATE'), CollectionPrivacy.private);
    });

    test('defaults to public for public string', () {
      expect(CollectionPrivacy.fromJson('public'), CollectionPrivacy.public);
    });

    test('defaults to public for unknown value', () {
      expect(CollectionPrivacy.fromJson('unknown'), CollectionPrivacy.public);
    });

    test('toJson returns lowercase string', () {
      expect(CollectionPrivacy.public.toJson(), 'public');
      expect(CollectionPrivacy.private.toJson(), 'private');
    });
  });
}
