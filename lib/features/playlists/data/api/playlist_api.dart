import 'dart:io';

import 'package:dio/dio.dart';
import 'package:software_project/core/network/api_endpoints.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../dto/paginated_dto.dart';
import '../dto/playlist_dto.dart';
import '../dto/playlist_summary_dto.dart';
import '../dto/playlist_track_dto.dart';

/// All 17 Module-7 endpoints wired to Dio.
///
/// Cover image strategy (both create and update):
///   - [cover] File  → multipart/form-data with 'cover' field (takes precedence)
///   - [coverUrl] String → JSON payload with 'coverUrl' field
///   - Both provided  → file wins; coverUrl is ignored
///   - Neither        → no cover sent
class PlaylistApi {
  PlaylistApi(this._dio);
  final Dio _dio;

  // ─── POST /collections ────────────────────────────────────────────────────

  Future<PlaylistDto> createCollection({
    required String title,
    required CollectionType type,
    required CollectionPrivacy privacy,
    String? description,
    File? cover,
    String? coverUrl,
  }) async {
    final res = cover != null
        // File upload path — multipart/form-data.
        ? await _dio.post<Map<String, dynamic>>(
            ApiEndpoints.collections,
            data: FormData.fromMap({
              'title': title,
              'type': type.toJson(),
              'privacy': privacy.toJson(),
              if (description != null) 'description': description,
              'cover': await MultipartFile.fromFile(cover.path),
            }),
          )
        // JSON path — coverUrl or no cover.
        : await _dio.post<Map<String, dynamic>>(
            ApiEndpoints.collections,
            data: {
              'title': title,
              'type': type.toJson(),
              'privacy': privacy.toJson(),
              if (description != null) 'description': description,
              if (coverUrl != null) 'coverUrl': coverUrl,
            },
          );
    return PlaylistDto.fromJson(res.data!);
  }

  // ─── GET /collections/me ──────────────────────────────────────────────────

  Future<PaginatedDto<PlaylistSummaryDto>> getMyCollections({
    int page = 1,
    int limit = 10,
    CollectionType? type,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.myCollections,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type.toJson(),
      },
    );
    return PaginatedDto.fromJson(res.data!, PlaylistSummaryDto.fromJson);
  }

  // ─── GET /collections/token/:token ───────────────────────────────────────

  Future<PlaylistDto> getCollectionByToken(String token) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.collectionByToken(token),
    );
    return PlaylistDto.fromJson(res.data!);
  }

  // ─── GET /collections/:id ────────────────────────────────────────────────

  Future<PlaylistDto> getCollectionById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.collectionById(id),
    );
    return PlaylistDto.fromJson(res.data!);
  }

  // ─── PUT /collections/:id ────────────────────────────────────────────────

  Future<PlaylistDto> updateCollection({
    required String id,
    String? title,
    String? description,
    CollectionPrivacy? privacy,
    File? cover,
    String? coverUrl,
  }) async {
    final res = cover != null
        // File upload path — multipart/form-data.
        ? await _dio.put<Map<String, dynamic>>(
            ApiEndpoints.collectionById(id),
            data: FormData.fromMap({
              if (title != null) 'title': title,
              if (description != null) 'description': description,
              if (privacy != null) 'privacy': privacy.toJson(),
              'cover': await MultipartFile.fromFile(cover.path),
            }),
          )
        // JSON path — coverUrl or no cover.
        : await _dio.put<Map<String, dynamic>>(
            ApiEndpoints.collectionById(id),
            data: {
              if (title != null) 'title': title,
              if (description != null) 'description': description,
              if (privacy != null) 'privacy': privacy.toJson(),
              if (coverUrl != null) 'coverUrl': coverUrl,
            },
          );
    return PlaylistDto.fromJson(res.data!);
  }

  // ─── DELETE /collections/:id ─────────────────────────────────────────────

  Future<void> deleteCollection(String id) =>
      _dio.delete<void>(ApiEndpoints.collectionById(id));

  // ─── GET /collections/:id/tracks ─────────────────────────────────────────

  Future<PaginatedDto<PlaylistTrackDto>> getCollectionTracks({
    required String id,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.collectionTracks(id),
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedDto.fromJson(res.data!, PlaylistTrackDto.fromJson);
  }

  // ─── POST /collections/:id/tracks/add ────────────────────────────────────

  Future<void> addTrack({
    required String collectionId,
    required String trackId,
  }) => _dio.post<void>(
    ApiEndpoints.collectionTracksAdd(collectionId),
    data: {'trackId': trackId},
  );

  // ─── POST /collections/:id/tracks/remove ─────────────────────────────────

  Future<void> removeTrack({
    required String collectionId,
    required String trackId,
  }) => _dio.post<void>(
    ApiEndpoints.collectionTracksRemove(collectionId),
    data: {'trackId': trackId},
  );

  // ─── PUT /collections/:id/tracks/reorder ─────────────────────────────────

  Future<void> reorderTracks({
    required String collectionId,
    required List<String> trackIds,
  }) => _dio.put<void>(
    ApiEndpoints.collectionTracksReorder(collectionId),
    data: {'trackIds': trackIds},
  );

  // ─── POST /collections/:id/like ──────────────────────────────────────────

  Future<void> likeCollection(String id) =>
      _dio.post<void>(ApiEndpoints.collectionLike(id));

  // ─── DELETE /collections/:id/like ────────────────────────────────────────

  Future<void> unlikeCollection(String id) =>
      _dio.delete<void>(ApiEndpoints.collectionLike(id));

  // ─── GET /collections/:id/embed ──────────────────────────────────────────

  Future<String> getEmbedCode(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.collectionEmbed(id),
    );
    return res.data!['embedCode'] as String;
  }

  // ─── GET /users/:username/collections|albums|playlists ───────────────────

  Future<PaginatedDto<PlaylistSummaryDto>> getUserCollections({
    required String username,
    int page = 1,
    int limit = 10,
  }) => _getUserEndpoint(
    ApiEndpoints.userCollections(username),
    page: page,
    limit: limit,
  );

  Future<PaginatedDto<PlaylistSummaryDto>> getUserAlbums({
    required String username,
    int page = 1,
    int limit = 10,
  }) => _getUserEndpoint(
    ApiEndpoints.userAlbums(username),
    page: page,
    limit: limit,
  );

  Future<PaginatedDto<PlaylistSummaryDto>> getUserPlaylists({
    required String username,
    int page = 1,
    int limit = 10,
  }) => _getUserEndpoint(
    ApiEndpoints.userPlaylists(username),
    page: page,
    limit: limit,
  );

  Future<PaginatedDto<PlaylistSummaryDto>> _getUserEndpoint(
    String path, {
    required int page,
    required int limit,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedDto.fromJson(res.data!, PlaylistSummaryDto.fromJson);
  }
}
