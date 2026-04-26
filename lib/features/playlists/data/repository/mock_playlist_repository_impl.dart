import 'dart:io';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/paginated_playlists.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../dto/paginated_dto.dart';
import '../dto/playlist_dto.dart';
import '../dto/playlist_summary_dto.dart';
import '../dto/playlist_track_dto.dart';
import '../mappers/playlist_mapper.dart';
import '../services/mock_playlist_store.dart';

/// In-memory implementation for development / test.
/// Mirrors [RealPlaylistRepositoryImpl] so providers can swap transparently.
class MockPlaylistRepositoryImpl implements PlaylistRepository {
  MockPlaylistRepositoryImpl(this._store);
  final MockPlaylistStore _store;

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _newId() => 'pl-${DateTime.now().microsecondsSinceEpoch}';

  PlaylistDto _require(String id) {
    final dto = _store.collections[id];
    if (dto == null) throw Exception('Collection $id not found');
    return dto;
  }

  /// Converts store map to a paginated [PlaylistSummaryEntity] result.
  PaginatedPlaylists _paginateSummaries(
    List<PlaylistDto> filtered,
    int page,
    int limit,
  ) {
    final total = filtered.length;
    final start = ((page - 1) * limit).clamp(0, total);
    final end = (start + limit).clamp(0, total);
    final slice = filtered.sublist(start, end);

    final summaryDtos = slice
        .map(
          (d) => PlaylistSummaryDto(
            id: d.id,
            title: d.title,
            description: d.description,
            type: d.type,
            privacy: d.privacy,
            coverUrl: d.coverUrl,
            trackCount: d.trackCount,
            likeCount: d.likeCount,
            repostsCount: d.repostsCount,
            ownerFollowerCount: d.ownerFollowerCount,
            isMine: d.owner?.id == MockPlaylistStore.currentUserId,
            isLiked: _store.likedCollectionIds.contains(d.id),
            createdAt: d.createdAt,
            updatedAt: d.updatedAt,
          ),
        )
        .toList();

    return PlaylistMapper.paginatedSummaries(
      PaginatedDto(
        items: summaryDtos,
        total: total,
        page: page,
        limit: limit,
        hasMore: end < total,
      ),
    );
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────

  @override
  Future<PlaylistEntity> createCollection({
    required String title,
    required CollectionType type,
    required CollectionPrivacy privacy,
    String? description,
    File? cover,
    String? coverUrl,
  }) async {
    final id = _newId();
    final now = DateTime.now().toIso8601String();
    final dto = PlaylistDto(
      id: id,
      title: title,
      description: description,
      type: type.toJson(),
      privacy: privacy.toJson(),
      secretToken: privacy == CollectionPrivacy.private
          ? 'mock_token_${id.hashCode.abs()}'
          : null,
      coverUrl: cover != null ? null : coverUrl,
      trackCount: 0,
      likeCount: 0,
      repostsCount: 0,
      ownerFollowerCount: 0,
      isLiked: false,
      owner: PlaylistOwnerDto(
        id: MockPlaylistStore.currentUserId,
        username: MockPlaylistStore.currentUsername,
        displayName: 'Mock User',
        avatarUrl: null,
        followerCount: 0,
      ),
      createdAt: now,
      updatedAt: now,
    );
    _store.collections[id] = dto;
    _store.tracks[id] = [];
    return PlaylistMapper.playlist(dto);
  }

  @override
  Future<PaginatedPlaylists> getMyCollections({
    int page = 1,
    int limit = 10,
    CollectionType? type,
  }) async {
    var all = _store.collections.values
        .where((d) => d.owner?.id == MockPlaylistStore.currentUserId)
        .toList();

    if (type != null) {
      all = all.where((d) => d.type == type.toJson()).toList();
    }

    return _paginateSummaries(all, page, limit);
  }

  @override
  Future<PlaylistEntity> getCollectionByToken(String token) async {
    final dto = _store.collections.values.firstWhere(
      (d) => d.secretToken == token,
      orElse: () => throw Exception('Token not found'),
    );
    return PlaylistMapper.playlist(dto);
  }

  @override
  Future<PlaylistEntity> getCollectionById(String id) async =>
      PlaylistMapper.playlist(_require(id));

  @override
  Future<PlaylistEntity> updateCollection({
    required String id,
    String? title,
    String? description,
    CollectionPrivacy? privacy,
    File? cover,
    String? coverUrl,
  }) async {
    final old = _require(id);
    final newPrivacy = privacy ?? CollectionPrivacy.fromJson(old.privacy);
    final isNowPrivate = newPrivacy == CollectionPrivacy.private;
    final wasPrivate =
        CollectionPrivacy.fromJson(old.privacy) == CollectionPrivacy.private;

    // Token logic: generate on private transition, clear on public transition.
    final String? newToken = isNowPrivate
        ? (wasPrivate
              ? old.secretToken
              : 'mock_token_${DateTime.now().microsecondsSinceEpoch}')
        : null;

    final updated = PlaylistDto(
      id: old.id,
      title: title ?? old.title,
      description: description ?? old.description,
      type: old.type,
      privacy: newPrivacy.toJson(),
      secretToken: newToken,
      coverUrl: cover != null ? old.coverUrl : (coverUrl ?? old.coverUrl),
      trackCount: old.trackCount,
      likeCount: old.likeCount,
      repostsCount: old.repostsCount,
      ownerFollowerCount: old.ownerFollowerCount,
      isLiked: old.isLiked,
      owner: old.owner,
      createdAt: old.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    _store.collections[id] = updated;
    return PlaylistMapper.playlist(updated);
  }

  @override
  Future<void> deleteCollection(String id) async {
    _require(id);
    _store.collections.remove(id);
    _store.tracks.remove(id);
  }

  // ─── Track management ────────────────────────────────────────────────────

  @override
  Future<PaginatedPlaylistTracks> getCollectionTracks({
    required String collectionId,
    int page = 1,
    int limit = 10,
  }) async {
    _require(collectionId);
    final all = List<PlaylistTrackDto>.from(_store.tracks[collectionId] ?? []);
    final total = all.length;
    final start = ((page - 1) * limit).clamp(0, total);
    final end = (start + limit).clamp(0, total);

    return PlaylistMapper.paginatedTracks(
      PaginatedDto(
        items: all.sublist(start, end),
        total: total,
        page: page,
        limit: limit,
        hasMore: end < total,
      ),
    );
  }

  @override
  Future<void> addTrack({
    required String collectionId,
    required String trackId,
  }) async {
    final col = _require(collectionId);
    final list = _store.tracks.putIfAbsent(collectionId, () => []);

    if (list.any((t) => t.trackId == trackId)) {
      throw Exception('Track already in collection');
    }

    final position = list.length + 1;
    list.add(
      PlaylistTrackDto(
        position: position,
        addedAt: DateTime.now().toIso8601String(),
        trackId: trackId,
        title: 'Track $trackId',
        durationSeconds: 180,
        coverUrl: null,
        genreId: null,
        isPublic: true,
        playCount: 0,
        ownerId: MockPlaylistStore.currentUserId,
        ownerUsername: MockPlaylistStore.currentUsername,
        ownerDisplayName: 'Mock User',
        ownerAvatarUrl: null,
      ),
    );

    // Update trackCount on the parent collection.
    _store.collections[collectionId] = PlaylistDto(
      id: col.id,
      title: col.title,
      description: col.description,
      type: col.type,
      privacy: col.privacy,
      secretToken: col.secretToken,
      coverUrl: col.coverUrl,
      trackCount: list.length,
      likeCount: col.likeCount,
      repostsCount: col.repostsCount,
      ownerFollowerCount: col.ownerFollowerCount,
      isLiked: col.isLiked,
      owner: col.owner,
      createdAt: col.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> removeTrack({
    required String collectionId,
    required String trackId,
  }) async {
    final col = _require(collectionId);
    final list = _store.tracks[collectionId] ?? [];
    final before = list.length;

    list.removeWhere((t) => t.trackId == trackId);

    if (list.length == before) {
      throw Exception('Track not found in collection');
    }

    // Re-normalise positions after removal (no gaps).
    for (var i = 0; i < list.length; i++) {
      final t = list[i];
      list[i] = PlaylistTrackDto(
        position: i + 1,
        addedAt: t.addedAt,
        trackId: t.trackId,
        title: t.title,
        durationSeconds: t.durationSeconds,
        coverUrl: t.coverUrl,
        genreId: t.genreId,
        isPublic: t.isPublic,
        playCount: t.playCount,
        ownerId: t.ownerId,
        ownerUsername: t.ownerUsername,
        ownerDisplayName: t.ownerDisplayName,
        ownerAvatarUrl: t.ownerAvatarUrl,
      );
    }

    _store.collections[collectionId] = PlaylistDto(
      id: col.id,
      title: col.title,
      description: col.description,
      type: col.type,
      privacy: col.privacy,
      secretToken: col.secretToken,
      coverUrl: col.coverUrl,
      trackCount: list.length,
      likeCount: col.likeCount,
      repostsCount: col.repostsCount,
      ownerFollowerCount: col.ownerFollowerCount,
      isLiked: col.isLiked,
      owner: col.owner,
      createdAt: col.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> reorderTracks({
    required String collectionId,
    required List<String> trackIds,
  }) async {
    _require(collectionId);
    final list = _store.tracks[collectionId] ?? [];

    // Validate: same set of IDs, no extras, no omissions.
    final currentIds = list.map((t) => t.trackId).toSet();
    final incomingIds = trackIds.toSet();
    if (currentIds.length != incomingIds.length ||
        !currentIds.containsAll(incomingIds)) {
      throw Exception(
        'trackIds must contain exactly the current tracks in the collection',
      );
    }

    // Rebuild list in the given order with updated positions.
    final byId = {for (final t in list) t.trackId: t};
    _store.tracks[collectionId] = [
      for (var i = 0; i < trackIds.length; i++)
        PlaylistTrackDto(
          position: i + 1,
          addedAt: byId[trackIds[i]]!.addedAt,
          trackId: trackIds[i],
          title: byId[trackIds[i]]!.title,
          durationSeconds: byId[trackIds[i]]!.durationSeconds,
          coverUrl: byId[trackIds[i]]!.coverUrl,
          genreId: byId[trackIds[i]]!.genreId,
          isPublic: byId[trackIds[i]]!.isPublic,
          playCount: byId[trackIds[i]]!.playCount,
          ownerId: byId[trackIds[i]]!.ownerId,
          ownerUsername: byId[trackIds[i]]!.ownerUsername,
          ownerDisplayName: byId[trackIds[i]]!.ownerDisplayName,
          ownerAvatarUrl: byId[trackIds[i]]!.ownerAvatarUrl,
        ),
    ];
  }

  // ─── Likes ───────────────────────────────────────────────────────────────

  @override
  Future<void> likeCollection(String id) async {
    _require(id);
    if (_store.likedCollectionIds.contains(id)) {
      throw Exception('Already liked');
    }
    _store.likedCollectionIds.add(id);
    final col = _store.collections[id]!;
    _store.collections[id] = PlaylistDto(
      id: col.id,
      title: col.title,
      description: col.description,
      type: col.type,
      privacy: col.privacy,
      secretToken: col.secretToken,
      coverUrl: col.coverUrl,
      trackCount: col.trackCount,
      likeCount: col.likeCount + 1,
      repostsCount: col.repostsCount,
      ownerFollowerCount: col.ownerFollowerCount,
      isLiked: true,
      owner: col.owner,
      createdAt: col.createdAt,
      updatedAt: col.updatedAt,
    );
  }

  @override
  Future<void> unlikeCollection(String id) async {
    _require(id);
    if (!_store.likedCollectionIds.contains(id)) {
      throw Exception('Not liked');
    }
    _store.likedCollectionIds.remove(id);
    final col = _store.collections[id]!;
    _store.collections[id] = PlaylistDto(
      id: col.id,
      title: col.title,
      description: col.description,
      type: col.type,
      privacy: col.privacy,
      secretToken: col.secretToken,
      coverUrl: col.coverUrl,
      trackCount: col.trackCount,
      likeCount: (col.likeCount - 1).clamp(0, 999999),
      repostsCount: col.repostsCount,
      ownerFollowerCount: col.ownerFollowerCount,
      isLiked: false,
      owner: col.owner,
      createdAt: col.createdAt,
      updatedAt: col.updatedAt,
    );
  }

  // ─── Embed ───────────────────────────────────────────────────────────────

  @override
  Future<String> getEmbedCode(String id) async {
    final col = _require(id);
    if (CollectionPrivacy.fromJson(col.privacy) == CollectionPrivacy.private) {
      throw Exception('Cannot embed a private collection');
    }
    return '<iframe src="https://tunify.duckdns.org/embed/collections/$id" '
        'width="100%" height="166" frameborder="0"></iframe>';
  }

  // ─── User collections ────────────────────────────────────────────────────

  @override
  Future<PaginatedPlaylists> getUserCollections({
    required String username,
    int page = 1,
    int limit = 10,
  }) async {
    final all = _store.collections.values
        .where((d) => d.owner?.username == username)
        .toList();
    return _paginateSummaries(all, page, limit);
  }

  @override
  Future<PaginatedPlaylists> getUserAlbums({
    required String username,
    int page = 1,
    int limit = 10,
  }) async {
    final all = _store.collections.values
        .where(
          (d) =>
              d.owner?.username == username &&
              d.type == CollectionType.album.toJson(),
        )
        .toList();
    return _paginateSummaries(all, page, limit);
  }

  @override
  Future<PaginatedPlaylists> getUserPlaylists({
    required String username,
    int page = 1,
    int limit = 10,
  }) async {
    final all = _store.collections.values
        .where(
          (d) =>
              d.owner?.username == username &&
              d.type == CollectionType.playlist.toJson(),
        )
        .toList();
    return _paginateSummaries(all, page, limit);
  }
}
