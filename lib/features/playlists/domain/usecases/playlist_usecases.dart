import 'dart:io';

import '../entities/collection_privacy.dart';
import '../entities/collection_type.dart';
import '../entities/paginated_playlists.dart';
import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

// ─── Create ──────────────────────────────────────────────────────────────────

class CreatePlaylistUseCase {
  const CreatePlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<PlaylistEntity> call({
    required String title,
    required CollectionType type,
    required CollectionPrivacy privacy,
    String? description,
    File? cover,
    String? coverUrl,
  }) => _repository.createCollection(
    title: title,
    type: type,
    privacy: privacy,
    description: description,
    cover: cover,
    coverUrl: coverUrl,
  );
}

// ─── Edit ─────────────────────────────────────────────────────────────────────

class EditPlaylistUseCase {
  const EditPlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<PlaylistEntity> call({
    required String id,
    String? title,
    String? description,
    CollectionPrivacy? privacy,
    File? cover,
    String? coverUrl,
  }) => _repository.updateCollection(
    id: id,
    title: title,
    description: description,
    privacy: privacy,
    cover: cover,
    coverUrl: coverUrl,
  );
}

// ─── Delete ───────────────────────────────────────────────────────────────────

class DeletePlaylistUseCase {
  const DeletePlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<void> call(String id) => _repository.deleteCollection(id);
}

// ─── Get ──────────────────────────────────────────────────────────────────────

/// Fetches a single collection by ID. Auth optional.
class GetPlaylistUseCase {
  const GetPlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<PlaylistEntity> call(String id) => _repository.getCollectionById(id);
}

/// Returns the authenticated user's own collections.
class GetMyPlaylistsUseCase {
  const GetMyPlaylistsUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<PaginatedPlaylists> call({
    int page = 1,
    int limit = 10,
    CollectionType? type,
  }) => _repository.getMyCollections(page: page, limit: limit, type: type);
}

// ─── Get tracks ───────────────────────────────────────────────────────────────

class GetTracksPerPlaylistUseCase {
  const GetTracksPerPlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<PaginatedPlaylistTracks> call({
    required String playlistId,
    int page = 1,
    int limit = 50,
  }) => _repository.getCollectionTracks(
    collectionId: playlistId,
    page: page,
    limit: limit,
  );
}

// ─── Reorder ──────────────────────────────────────────────────────────────────

/// Sends a full-replacement reorder to the backend.
/// [trackIds] must contain every track in the collection — no gaps, no extras.
class ReorderTracksUseCase {
  const ReorderTracksUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<void> call({
    required String collectionId,
    required List<String> trackIds,
  }) =>
      _repository.reorderTracks(collectionId: collectionId, trackIds: trackIds);
}

// ─── Add Track ────────────────────────────────────────────────────────────────

class AddTrackUseCase {
  const AddTrackUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<void> call({required String collectionId, required String trackId}) =>
      _repository.addTrack(collectionId: collectionId, trackId: trackId);
}

// ─── Remove Track ─────────────────────────────────────────────────────────────

class RemoveTrackUseCase {
  const RemoveTrackUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<void> call({required String collectionId, required String trackId}) =>
      _repository.removeTrack(collectionId: collectionId, trackId: trackId);
}
