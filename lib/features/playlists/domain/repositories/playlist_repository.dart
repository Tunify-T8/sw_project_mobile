import 'dart:io';

import '../entities/collection_type.dart';
import '../entities/collection_privacy.dart';
import '../entities/paginated_playlists.dart';
import '../entities/playlist_entity.dart';
import '../entities/playlist_summary_entity.dart';

/// Contract between domain use-cases and the data layer.
/// Implemented by [MockPlaylistRepositoryImpl] and [RealPlaylistRepositoryImpl].
abstract class PlaylistRepository {
  // CRUD

  /// Creates a new collection. [cover] is optional.
  Future<PlaylistEntity> createCollection({
    required String title,
    required CollectionType type,
    required CollectionPrivacy privacy,
    String? description,
    File? cover,
    String? coverUrl,
  });

  /// Returns all collections owned by the authenticated user.
  Future<PaginatedPlaylists> getMyCollections({
    int page = 1,
    int limit = 10,
    CollectionType? type,
  });

  /// Fetches a private collection using its secret token.
  /// No auth required — anyone with the token can access it.
  Future<PlaylistEntity> getCollectionByToken(String token);

  /// Fetches a collection by its UUID. Auth optional.
  Future<PlaylistEntity> getCollectionById(String id);

  /// Updates a collection. Only send fields you want to change.
  Future<PlaylistEntity> updateCollection({
    required String id,
    String? title,
    String? description,
    CollectionPrivacy? privacy,
    File? cover,
    String? coverUrl,
  });

  /// Permanently deletes a collection.
  Future<void> deleteCollection(String id);

  // ─── Track management ────────────────────────────────────────────────────

  /// Returns the ordered track list for a collection.
  Future<PaginatedPlaylistTracks> getCollectionTracks({
    required String collectionId,
    int page = 1,
    int limit = 10,
  });

  /// Appends a track to the end of a collection.
  Future<void> addTrack({
    required String collectionId,
    required String trackId,
  });

  /// Removes a track from a collection.
  Future<void> removeTrack({
    required String collectionId,
    required String trackId,
  });

  /// Replaces the entire track order atomically.
  /// [trackIds] must contain ALL current tracks — no omissions, no extras.
  Future<void> reorderTracks({
    required String collectionId,
    required List<String> trackIds,
  });

  // ─── Likes ───────────────────────────────────────────────────────────────

  Future<void> likeCollection(String id);
  Future<void> unlikeCollection(String id);

  // ─── Embed ───────────────────────────────────────────────────────────────

  /// Returns the raw iframe HTML string for a public collection.
  Future<String> getEmbedCode(String id);

  // ─── User collections ────────────────────────────────────────────────────

  /// Returns all collections (public + private if owner) for a username.
  Future<PaginatedPlaylists> getUserCollections({
    required String username,
    int page = 1,
    int limit = 10,
  });

  /// Returns only albums for a username.
  Future<PaginatedPlaylists> getUserAlbums({
    required String username,
    int page = 1,
    int limit = 10,
  });

  /// Returns only playlists for a username.
  Future<PaginatedPlaylists> getUserPlaylists({
    required String username,
    int page = 1,
    int limit = 10,
  });
}
