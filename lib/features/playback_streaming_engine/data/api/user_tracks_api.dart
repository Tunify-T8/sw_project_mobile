import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';

/// Minimal DTO of one entry in `GET /users/{userId}/tracks`.
///
/// We only parse the fields the queue resolver actually needs (id, title,
/// artist name, duration, cover, status). The full response carries more
/// detail (engagement counters, interaction flags, scheduledReleaseDate,
/// etc.) but those are looked up later via the playback bundle endpoint
/// when the user actually advances to that track.
class UserTrackSummaryDto {
  const UserTrackSummaryDto({
    required this.id,
    required this.title,
    required this.artistName,
    required this.durationSeconds,
    required this.status,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String artistName;
  final int durationSeconds;

  /// Backend transcoding/lifecycle status. Only "finished" tracks are queued.
  final String status;
  final String? coverUrl;

  bool get isPlayable => status == 'finished';

  factory UserTrackSummaryDto.fromJson(Map<String, dynamic> json) {
    // Artist may arrive as a single object {id, displayName, ...} or as a
    // simple string. Handle both so a future backend tweak doesn't break us.
    String resolveArtistName(dynamic raw) {
      if (raw is String) return raw;
      if (raw is Map<String, dynamic>) {
        final display = raw['displayName'];
        if (display is String && display.trim().isNotEmpty) return display;
        final username = raw['username'];
        if (username is String && username.trim().isNotEmpty) return username;
      }
      return '';
    }

    return UserTrackSummaryDto(
      id: (json['id'] ?? json['trackId'] ?? '').toString(),
      title: (json['title'] as String?) ?? '',
      artistName: resolveArtistName(json['artist']),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'finished',
      coverUrl: json['coverUrl'] as String?,
    );
  }
}

class UserTracksApi {
  UserTracksApi(this._dio);

  final Dio _dio;

  /// Fetches the public tracks for [userId]. Returns an empty list on any
  /// error (404 user-not-found, 5xx, network, parse failure) so the queue
  /// resolver always has something to work with — the worst case is just a
  /// queue with only the current track in it, same as before this feature.
  Future<List<UserTrackSummaryDto>> getUserTracks(
    String userId, {
    int page = 1,
    int limit = 50,
  }) async {
    if (userId.trim().isEmpty) return const <UserTrackSummaryDto>[];

    try {
      final response = await _dio.get(
        ApiEndpoints.getUserTracks(userId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final body = response.data;
      // Response shape (per spec): { data: [...], meta: {...} }
      // Some backends return the array directly — handle both defensively.
      final List<dynamic> rawList = body is Map<String, dynamic>
          ? (body['data'] as List<dynamic>? ?? const <dynamic>[])
          : body is List<dynamic>
              ? body
              : const <dynamic>[];

      return rawList
          .whereType<Map<String, dynamic>>()
          .map(UserTrackSummaryDto.fromJson)
          .toList(growable: false);
    } catch (_) {
      // Swallow — falling back to an empty list means the queue just stays
      // small. We never want a backend hiccup to break audio playback.
      return const <UserTrackSummaryDto>[];
    }
  }
}