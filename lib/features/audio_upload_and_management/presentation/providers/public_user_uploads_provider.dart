import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/upload_item.dart';
import 'library_uploads_dependencies_provider.dart';

// Read-only list of another user's public tracks, backed by
// GET /users/{userId}/tracks. Shape mirrors PublicUserTracksDto on the
// backend — we only map the fields ProfileTracksSection actually renders
// (plus waveformUrl/privacy so the tile can hand off to TrackDetailScreen
// without a second fetch).
//
// Kept separate from libraryUploadsProvider because:
//   - libraryUploadsProvider is write-capable (delete / replace / update)
//     and caches the signed-in user's own uploads to secure storage. None
//     of that applies when we're just viewing a stranger's catalog.
//   - The minimal UserTracksApi next to this file is scoped to the queue
//     resolver and intentionally drops metadata we need here.
final publicUserUploadsProvider = FutureProvider.autoDispose
    .family<List<UploadItem>, String>((ref, userId) async {
  if (userId.trim().isEmpty) return const <UploadItem>[];

  final dio = ref.watch(libraryUploadsDioProvider);

  try {
    final response = await dio.get(
      ApiEndpoints.getUserTracks(userId),
      queryParameters: const {'page': 1, 'limit': 50},
    );

    final body = response.data;
    final List<dynamic> rawList = body is Map<String, dynamic>
        ? (body['data'] as List<dynamic>? ?? const <dynamic>[])
        : body is List<dynamic>
            ? body
            : const <dynamic>[];

    final now = DateTime.now();
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(_publicTrackJsonToUploadItem)
        .where(
          (track) =>
              track.visibility == UploadVisibility.public &&
              (track.scheduledReleaseDate == null ||
                  !track.scheduledReleaseDate!.isAfter(now)),
        )
        .toList(growable: false);
  } catch (_) {
    // Empty list keeps the profile screen's "No uploaded tracks yet." state
    // usable on transient failures instead of blowing up the whole page.
    return const <UploadItem>[];
  }
});

UploadItem _publicTrackJsonToUploadItem(Map<String, dynamic> json) {
  final duration = (json['durationSeconds'] as num?)?.toInt() ?? 0;
  final privacyRaw = (json['privacy'] as String?) ?? 'public';
  final statusRaw = (json['status'] as String?) ?? 'finished';
  final createdAtRaw = json['createdAt'];
  final scheduledRaw = json['scheduledReleaseDate'];

  return UploadItem(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] as String?) ?? '',
    artistDisplay: _artistDisplay(json['artist']),
    durationLabel: _formatDuration(duration),
    durationSeconds: duration,
    artworkUrl: json['coverUrl'] as String?,
    waveformUrl: json['waveformUrl'] as String?,
    visibility: privacyRaw == 'private'
        ? UploadVisibility.private
        : UploadVisibility.public,
    status: _statusFromString(statusRaw),
    isExplicit: false,
    genreCategory: (json['genre'] as String?) ?? '',
    scheduledReleaseDate: scheduledRaw is String
        ? DateTime.tryParse(scheduledRaw)
        : null,
    createdAt: createdAtRaw is String
        ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
        : DateTime.now(),
  );
}

String _artistDisplay(dynamic raw) {
  if (raw is String) return raw.trim();
  if (raw is Map<String, dynamic>) {
    final display = raw['displayName'];
    if (display is String && display.trim().isNotEmpty) {
      return display.trim();
    }
    final username = raw['username'];
    if (username is String && username.trim().isNotEmpty) {
      return username.trim();
    }
  }
  return '';
}

UploadProcessingStatus _statusFromString(String value) {
  switch (value) {
    case 'processing':
    case 'uploading':
      return UploadProcessingStatus.processing;
    case 'failed':
      return UploadProcessingStatus.failed;
    case 'deleted':
      return UploadProcessingStatus.deleted;
    default:
      return UploadProcessingStatus.finished;
  }
}

String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = safe ~/ 60;
  final seconds = safe % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
