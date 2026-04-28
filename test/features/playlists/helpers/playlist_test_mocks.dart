import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:software_project/features/playlists/domain/entities/collection_privacy.dart';
import 'package:software_project/features/playlists/domain/entities/collection_type.dart';
import 'package:software_project/features/playlists/domain/entities/paginated_playlists.dart';
import 'package:software_project/features/playlists/domain/entities/playlist_entity.dart';
import 'package:software_project/features/playlists/domain/entities/playlist_summary_entity.dart';
import 'package:software_project/features/playlists/domain/entities/playlist_track_entity.dart';
import 'package:software_project/features/playlists/domain/repositories/playlist_repository.dart';

const kPlaylistId = 'playlist-1';
const kTrackId = 'track-1';
const kUsername = 'testuser';

PlaylistEntity dummyPlaylist({
  String id = kPlaylistId,
  String title = 'My Playlist',
  CollectionType type = CollectionType.playlist,
  CollectionPrivacy privacy = CollectionPrivacy.public,
  int trackCount = 3,
  int likeCount = 10,
  bool isLiked = false,
}) =>
    PlaylistEntity(
      id: id,
      title: title,
      type: type,
      privacy: privacy,
      trackCount: trackCount,
      likeCount: likeCount,
      repostsCount: 0,
      ownerFollowerCount: 0,
      isLiked: isLiked,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

PlaylistSummaryEntity dummyPlaylistSummary({
  String id = kPlaylistId,
  String title = 'My Playlist',
  bool isMine = true,
  bool isLiked = false,
}) =>
    PlaylistSummaryEntity(
      id: id,
      title: title,
      type: CollectionType.playlist,
      privacy: CollectionPrivacy.public,
      trackCount: 3,
      likeCount: 10,
      repostsCount: 0,
      ownerFollowerCount: 0,
      isMine: isMine,
      isLiked: isLiked,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

PlaylistTrackEntity dummyPlaylistTrack({
  int position = 1,
  String trackId = kTrackId,
  String title = 'Test Track',
}) =>
    PlaylistTrackEntity(
      position: position,
      addedAt: DateTime(2026, 1, 1),
      trackId: trackId,
      title: title,
      durationSeconds: 180,
      isPublic: true,
      playCount: 100,
      ownerId: 'user-1',
      ownerUsername: kUsername,
    );

PaginatedPlaylists dummyPaginatedPlaylists({
  List<PlaylistSummaryEntity>? items,
}) =>
    PaginatedPlaylists(
      items: items ?? [dummyPlaylistSummary()],
      total: 1,
      page: 1,
      limit: 10,
      hasMore: false,
    );

PaginatedPlaylistTracks dummyPaginatedTracks({
  List<PlaylistTrackEntity>? items,
}) =>
    PaginatedPlaylistTracks(
      items: items ?? [dummyPlaylistTrack()],
      total: 1,
      page: 1,
      limit: 50,
      hasMore: false,
    );

class MockPlaylistRepository extends Mock implements PlaylistRepository {
  @override
  Future<PlaylistEntity> createCollection({
    required String title,
    required CollectionType type,
    required CollectionPrivacy privacy,
    String? description,
    File? cover,
    String? coverUrl,
  }) {
    return super.noSuchMethod(
      Invocation.method(#createCollection, [], {
        #title: title,
        #type: type,
        #privacy: privacy,
        #description: description,
        #cover: cover,
        #coverUrl: coverUrl,
      }),
      returnValue: Future.value(dummyPlaylist()),
      returnValueForMissingStub: Future.value(dummyPlaylist()),
    ) as Future<PlaylistEntity>;
  }

  @override
  Future<PlaylistEntity> getCollectionById(String id) {
    return super.noSuchMethod(
      Invocation.method(#getCollectionById, [id]),
      returnValue: Future.value(dummyPlaylist()),
      returnValueForMissingStub: Future.value(dummyPlaylist()),
    ) as Future<PlaylistEntity>;
  }

  @override
  Future<PlaylistEntity> getCollectionByToken(String token) {
    return super.noSuchMethod(
      Invocation.method(#getCollectionByToken, [token]),
      returnValue: Future.value(dummyPlaylist()),
      returnValueForMissingStub: Future.value(dummyPlaylist()),
    ) as Future<PlaylistEntity>;
  }

  @override
  Future<PaginatedPlaylists> getMyCollections({
    int page = 1,
    int limit = 10,
    CollectionType? type,
  }) {
    return super.noSuchMethod(
      Invocation.method(
          #getMyCollections, [], {#page: page, #limit: limit, #type: type}),
      returnValue: Future.value(dummyPaginatedPlaylists()),
      returnValueForMissingStub: Future.value(dummyPaginatedPlaylists()),
    ) as Future<PaginatedPlaylists>;
  }

  @override
  Future<PlaylistEntity> updateCollection({
    required String id,
    String? title,
    String? description,
    CollectionPrivacy? privacy,
    File? cover,
    String? coverUrl,
  }) {
    return super.noSuchMethod(
      Invocation.method(#updateCollection, [], {
        #id: id,
        #title: title,
        #description: description,
        #privacy: privacy,
        #cover: cover,
        #coverUrl: coverUrl,
      }),
      returnValue: Future.value(dummyPlaylist()),
      returnValueForMissingStub: Future.value(dummyPlaylist()),
    ) as Future<PlaylistEntity>;
  }

  @override
  Future<void> deleteCollection(String id) {
    return super.noSuchMethod(
      Invocation.method(#deleteCollection, [id]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<PaginatedPlaylistTracks> getCollectionTracks({
    required String collectionId,
    int page = 1,
    int limit = 10,
  }) {
    return super.noSuchMethod(
      Invocation.method(#getCollectionTracks, [], {
        #collectionId: collectionId,
        #page: page,
        #limit: limit,
      }),
      returnValue: Future.value(dummyPaginatedTracks()),
      returnValueForMissingStub: Future.value(dummyPaginatedTracks()),
    ) as Future<PaginatedPlaylistTracks>;
  }

  @override
  Future<void> addTrack({
    required String collectionId,
    required String trackId,
  }) {
    return super.noSuchMethod(
      Invocation.method(
          #addTrack, [], {#collectionId: collectionId, #trackId: trackId}),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> removeTrack({
    required String collectionId,
    required String trackId,
  }) {
    return super.noSuchMethod(
      Invocation.method(
          #removeTrack, [], {#collectionId: collectionId, #trackId: trackId}),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> reorderTracks({
    required String collectionId,
    required List<String> trackIds,
  }) {
    return super.noSuchMethod(
      Invocation.method(#reorderTracks, [], {
        #collectionId: collectionId,
        #trackIds: trackIds,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> likeCollection(String id) {
    return super.noSuchMethod(
      Invocation.method(#likeCollection, [id]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> unlikeCollection(String id) {
    return super.noSuchMethod(
      Invocation.method(#unlikeCollection, [id]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<String> getEmbedCode(String id) {
    return super.noSuchMethod(
      Invocation.method(#getEmbedCode, [id]),
      returnValue: Future.value('<iframe></iframe>'),
      returnValueForMissingStub: Future.value('<iframe></iframe>'),
    ) as Future<String>;
  }

  @override
  Future<String> getShareUrl(String id) {
    return super.noSuchMethod(
      Invocation.method(#getShareUrl, [id]),
      returnValue: Future.value('https://example.com/s/abc123'),
      returnValueForMissingStub: Future.value('https://example.com/s/abc123'),
    ) as Future<String>;
  }

  @override
  Future<String> resetShareToken(String id) {
    return super.noSuchMethod(
      Invocation.method(#resetShareToken, [id]),
      returnValue: Future.value('newtoken123'),
      returnValueForMissingStub: Future.value('newtoken123'),
    ) as Future<String>;
  }

  @override
  Future<PaginatedPlaylists> getUserCollections({
    required String username,
    int page = 1,
    int limit = 10,
  }) {
    return super.noSuchMethod(
      Invocation.method(#getUserCollections, [], {
        #username: username,
        #page: page,
        #limit: limit,
      }),
      returnValue: Future.value(dummyPaginatedPlaylists()),
      returnValueForMissingStub: Future.value(dummyPaginatedPlaylists()),
    ) as Future<PaginatedPlaylists>;
  }

  @override
  Future<PaginatedPlaylists> getUserAlbums({
    required String username,
    int page = 1,
    int limit = 10,
  }) {
    return super.noSuchMethod(
      Invocation.method(#getUserAlbums, [], {
        #username: username,
        #page: page,
        #limit: limit,
      }),
      returnValue: Future.value(dummyPaginatedPlaylists()),
      returnValueForMissingStub: Future.value(dummyPaginatedPlaylists()),
    ) as Future<PaginatedPlaylists>;
  }

  @override
  Future<PaginatedPlaylists> getUserPlaylists({
    required String username,
    int page = 1,
    int limit = 10,
  }) {
    return super.noSuchMethod(
      Invocation.method(#getUserPlaylists, [], {
        #username: username,
        #page: page,
        #limit: limit,
      }),
      returnValue: Future.value(dummyPaginatedPlaylists()),
      returnValueForMissingStub: Future.value(dummyPaginatedPlaylists()),
    ) as Future<PaginatedPlaylists>;
  }
}
