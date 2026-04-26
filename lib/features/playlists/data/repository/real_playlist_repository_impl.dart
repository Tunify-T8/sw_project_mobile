import 'dart:io';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/paginated_playlists.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../api/playlist_api.dart';
import '../mappers/playlist_mapper.dart';

/// Production implementation — delegates every call to [PlaylistApi].
class RealPlaylistRepositoryImpl implements PlaylistRepository {
  RealPlaylistRepositoryImpl(this._api);
  final PlaylistApi _api;

  @override
  Future<PlaylistEntity> createCollection({
    required String title,
    required CollectionType type,
    required CollectionPrivacy privacy,
    String? description,
    File? cover,
    String? coverUrl,
  }) async {
    final dto = await _api.createCollection(
      title: title,
      type: type,
      privacy: privacy,
      description: description,
      cover: cover,
      coverUrl: coverUrl,
    );
    return PlaylistMapper.playlist(dto);
  }

  @override
  Future<PaginatedPlaylists> getMyCollections({
    int page = 1,
    int limit = 10,
    CollectionType? type,
  }) async {
    final dto = await _api.getMyCollections(
      page: page,
      limit: limit,
      type: type,
    );
    return PlaylistMapper.paginatedSummaries(dto);
  }

  @override
  Future<PlaylistEntity> getCollectionByToken(String token) async {
    final dto = await _api.getCollectionByToken(token);
    return PlaylistMapper.playlist(dto);
  }

  @override
  Future<PlaylistEntity> getCollectionById(String id) async {
    final dto = await _api.getCollectionById(id);
    return PlaylistMapper.playlist(dto);
  }

  @override
  Future<PlaylistEntity> updateCollection({
    required String id,
    String? title,
    String? description,
    CollectionPrivacy? privacy,
    File? cover,
    String? coverUrl,
  }) async {
    final dto = await _api.updateCollection(
      id: id,
      title: title,
      description: description,
      privacy: privacy,
      cover: cover,
      coverUrl: coverUrl,
    );
    return PlaylistMapper.playlist(dto);
  }

  @override
  Future<void> deleteCollection(String id) => _api.deleteCollection(id);

  @override
  Future<PaginatedPlaylistTracks> getCollectionTracks({
    required String collectionId,
    int page = 1,
    int limit = 10,
  }) async {
    final dto = await _api.getCollectionTracks(
      id: collectionId,
      page: page,
      limit: limit,
    );
    return PlaylistMapper.paginatedTracks(dto);
  }

  @override
  Future<void> addTrack({
    required String collectionId,
    required String trackId,
  }) => _api.addTrack(collectionId: collectionId, trackId: trackId);

  @override
  Future<void> removeTrack({
    required String collectionId,
    required String trackId,
  }) => _api.removeTrack(collectionId: collectionId, trackId: trackId);

  @override
  Future<void> reorderTracks({
    required String collectionId,
    required List<String> trackIds,
  }) => _api.reorderTracks(collectionId: collectionId, trackIds: trackIds);

  @override
  Future<void> likeCollection(String id) => _api.likeCollection(id);

  @override
  Future<void> unlikeCollection(String id) => _api.unlikeCollection(id);

  @override
  Future<String> getEmbedCode(String id) => _api.getEmbedCode(id);

  @override
  Future<PaginatedPlaylists> getUserCollections({
    required String username,
    int page = 1,
    int limit = 10,
  }) async {
    final dto = await _api.getUserCollections(
      username: username,
      page: page,
      limit: limit,
    );
    return PlaylistMapper.paginatedSummaries(dto);
  }

  @override
  Future<PaginatedPlaylists> getUserAlbums({
    required String username,
    int page = 1,
    int limit = 10,
  }) async {
    final dto = await _api.getUserAlbums(
      username: username,
      page: page,
      limit: limit,
    );
    return PlaylistMapper.paginatedSummaries(dto);
  }

  @override
  Future<PaginatedPlaylists> getUserPlaylists({
    required String username,
    int page = 1,
    int limit = 10,
  }) async {
    final dto = await _api.getUserPlaylists(
      username: username,
      page: page,
      limit: limit,
    );
    return PlaylistMapper.paginatedSummaries(dto);
  }
}
