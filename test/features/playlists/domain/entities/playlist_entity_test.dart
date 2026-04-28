import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playlists/domain/entities/collection_privacy.dart';
import 'package:software_project/features/playlists/domain/entities/collection_type.dart';
import 'package:software_project/features/playlists/domain/entities/playlist_entity.dart';
import 'package:software_project/features/playlists/domain/entities/playlist_owner_entity.dart';

PlaylistOwnerEntity _owner({
  String id = 'owner-1',
  String username = 'artist',
  String? displayName = 'The Artist',
  String? avatarUrl,
  int followerCount = 100,
}) =>
    PlaylistOwnerEntity(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      followerCount: followerCount,
    );

PlaylistEntity _playlist({
  String id = 'p-1',
  String title = 'Test Playlist',
  String? description,
  CollectionType type = CollectionType.playlist,
  CollectionPrivacy privacy = CollectionPrivacy.public,
  String? secretToken,
  String? coverUrl,
  int trackCount = 5,
  int likeCount = 10,
  int repostsCount = 2,
  int ownerFollowerCount = 50,
  bool isLiked = false,
  PlaylistOwnerEntity? owner,
}) =>
    PlaylistEntity(
      id: id,
      title: title,
      description: description,
      type: type,
      privacy: privacy,
      secretToken: secretToken,
      coverUrl: coverUrl,
      trackCount: trackCount,
      likeCount: likeCount,
      repostsCount: repostsCount,
      ownerFollowerCount: ownerFollowerCount,
      isLiked: isLiked,
      owner: owner,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('PlaylistOwnerEntity', () {
    test('holds all required fields', () {
      final owner = _owner();

      expect(owner.id, 'owner-1');
      expect(owner.username, 'artist');
      expect(owner.followerCount, 100);
    });

    test('optional displayName is preserved', () {
      final owner = _owner(displayName: 'DJ Name');

      expect(owner.displayName, 'DJ Name');
    });

    test('displayName is null when not provided', () {
      final owner = _owner(displayName: null);

      expect(owner.displayName, isNull);
    });

    test('optional avatarUrl is preserved', () {
      final owner = _owner(avatarUrl: 'https://cdn.example.com/avatar.png');

      expect(owner.avatarUrl, 'https://cdn.example.com/avatar.png');
    });

    test('avatarUrl is null when not provided', () {
      final owner = _owner(avatarUrl: null);

      expect(owner.avatarUrl, isNull);
    });

    test('followerCount of zero is valid', () {
      final owner = _owner(followerCount: 0);

      expect(owner.followerCount, 0);
    });
  });

  group('PlaylistEntity.copyWith', () {
    test('preserves all fields when called with no arguments', () {
      final original = _playlist(
        id: 'p-original',
        title: 'Original',
        description: 'desc',
        type: CollectionType.album,
        privacy: CollectionPrivacy.private,
        secretToken: 'token123',
        coverUrl: 'https://cdn.example.com/cover.jpg',
        trackCount: 8,
        likeCount: 20,
        repostsCount: 4,
        ownerFollowerCount: 200,
        isLiked: true,
        owner: _owner(),
      );
      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.title, original.title);
      expect(copied.description, original.description);
      expect(copied.type, original.type);
      expect(copied.privacy, original.privacy);
      expect(copied.secretToken, original.secretToken);
      expect(copied.coverUrl, original.coverUrl);
      expect(copied.trackCount, original.trackCount);
      expect(copied.likeCount, original.likeCount);
      expect(copied.repostsCount, original.repostsCount);
      expect(copied.ownerFollowerCount, original.ownerFollowerCount);
      expect(copied.isLiked, original.isLiked);
      expect(copied.owner, original.owner);
      expect(copied.createdAt, original.createdAt);
      expect(copied.updatedAt, original.updatedAt);
    });

    test('overrides id', () {
      final updated = _playlist().copyWith(id: 'p-new');
      expect(updated.id, 'p-new');
    });

    test('overrides title', () {
      final updated = _playlist().copyWith(title: 'New Title');
      expect(updated.title, 'New Title');
    });

    test('overrides description', () {
      final updated = _playlist().copyWith(description: 'Updated desc');
      expect(updated.description, 'Updated desc');
    });

    test('overrides type to album', () {
      final updated = _playlist().copyWith(type: CollectionType.album);
      expect(updated.type, CollectionType.album);
    });

    test('overrides privacy to private', () {
      final updated = _playlist().copyWith(privacy: CollectionPrivacy.private);
      expect(updated.privacy, CollectionPrivacy.private);
    });

    test('overrides secretToken', () {
      final updated = _playlist().copyWith(secretToken: 'newtoken');
      expect(updated.secretToken, 'newtoken');
    });

    test('overrides coverUrl', () {
      final updated =
          _playlist().copyWith(coverUrl: 'https://cdn.example.com/new.jpg');
      expect(updated.coverUrl, 'https://cdn.example.com/new.jpg');
    });

    test('overrides trackCount', () {
      final updated = _playlist().copyWith(trackCount: 15);
      expect(updated.trackCount, 15);
    });

    test('overrides likeCount', () {
      final updated = _playlist().copyWith(likeCount: 99);
      expect(updated.likeCount, 99);
    });

    test('overrides repostsCount', () {
      final updated = _playlist().copyWith(repostsCount: 7);
      expect(updated.repostsCount, 7);
    });

    test('overrides ownerFollowerCount', () {
      final updated = _playlist().copyWith(ownerFollowerCount: 500);
      expect(updated.ownerFollowerCount, 500);
    });

    test('overrides isLiked to true', () {
      final updated = _playlist(isLiked: false).copyWith(isLiked: true);
      expect(updated.isLiked, isTrue);
    });

    test('overrides owner', () {
      final newOwner = _owner(id: 'owner-2', username: 'dj');
      final updated = _playlist().copyWith(owner: newOwner);
      expect(updated.owner!.id, 'owner-2');
      expect(updated.owner!.username, 'dj');
    });

    test('overrides createdAt', () {
      final newDate = DateTime(2025, 6, 15);
      final updated = _playlist().copyWith(createdAt: newDate);
      expect(updated.createdAt, newDate);
    });

    test('overrides updatedAt', () {
      final newDate = DateTime(2026, 3, 10);
      final updated = _playlist().copyWith(updatedAt: newDate);
      expect(updated.updatedAt, newDate);
    });

    test('non-overridden fields are unchanged when some fields are updated', () {
      final original = _playlist(title: 'Keep Me', trackCount: 3);
      final updated = original.copyWith(likeCount: 42);

      expect(updated.title, 'Keep Me');
      expect(updated.trackCount, 3);
      expect(updated.likeCount, 42);
    });
  });
}
