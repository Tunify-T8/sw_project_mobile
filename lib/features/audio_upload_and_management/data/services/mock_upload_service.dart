import 'dart:async';
import 'global_track_store.dart';
import '../../domain/entities/upload_item.dart';

/// Simulates the backend upload flow.
/// After pollTrackStatus completes → saves finished track to GlobalTrackStore
/// with the real localFilePath so waveform generation works in TrackDetailScreen.
class MockUploadService {
  final Map<String, Map<String, dynamic>> _tracks = {};
  // Stores the real local file path per trackId for waveform
  final Map<String, String> _localFilePaths = {};

  Future<Map<String, dynamic>> getUploadQuota({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'tier': 'free',
      'uploadMinutesLimit': 180,
      'uploadMinutesUsed': 8,
      'uploadMinutesRemaining': 172,
      'canReplaceFiles': false,
      'canScheduleRelease': false,
      'canAccessAdvancedTab': false,
    };
  }

  Future<Map<String, dynamic>> createTrack({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final trackId = 'track_${DateTime.now().millisecondsSinceEpoch}';
    final track = {
      'trackId': trackId,
      'status': 'idle',
      'title': '',
      'description': '',
      'genre': '',
      'tags': <String>[],
      'artists': <String>['ROZANA AHMED'],
      'durationSeconds': null,
      'privacy': 'public',
      'scheduledReleaseDate': null,
      'availability': {'type': 'worldwide', 'regions': <String>[]},
      'licensing': {
        'type': 'all_rights_reserved',
        'allowAttribution': false,
        'nonCommercial': false,
        'noDerivatives': false,
        'shareAlike': false,
      },
      'recordLabel': '',
      'publisher': '',
      'isrc': '',
      'pLine': '',
      'contentWarning': false,
      'permissions': {
        'enableDirectDownloads': false,
        'enableOfflineListening': false,
        'includeInRSS': true,
        'displayEmbedCode': true,
        'enableAppPlayback': true,
        'allowComments': true,
        'showCommentsPublic': true,
        'showInsightsPublic': false,
      },
      'audioUrl': null,
      'waveformUrl': null,
      'artworkUrl': null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'audioMetadata': null,
    };
    _tracks[trackId] = track;
    return Map<String, dynamic>.from(track);
  }

  Stream<double> uploadProgress() async* {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      yield i / 10.0;
    }
  }

  Future<Map<String, dynamic>> uploadAudio({
    required String trackId,
    String? localFilePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (localFilePath != null) {
      _localFilePaths[trackId] = localFilePath;
    }
    final existing = _tracks[trackId] ?? {'trackId': trackId, 'createdAt': DateTime.now().toIso8601String()};
    final updated = {
      ...existing,
      'trackId': trackId,
      'status': 'uploading',
      'audioUrl': null,
      'waveformUrl': null,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _tracks[trackId] = updated;
    return Map<String, dynamic>.from(updated);
  }

  Future<Map<String, dynamic>> replaceAudio({required String trackId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existing = _tracks[trackId] ?? {'trackId': trackId, 'createdAt': DateTime.now().toIso8601String()};
    final updated = {
      ...existing,
      'trackId': trackId,
      'status': 'processing',
      'audioUrl': null,
      'waveformUrl': null,
      'durationSeconds': null,
      'audioMetadata': null,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _tracks[trackId] = updated;
    return Map<String, dynamic>.from(updated);
  }

  Future<Map<String, dynamic>> finalizeMetadata({
    required String trackId,
    required Map<String, dynamic> metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final existing = _tracks[trackId] ?? {'trackId': trackId, 'createdAt': DateTime.now().toIso8601String()};

    // Keep the local artwork path for display
    final artworkPath = metadata['artworkPath'] as String?;

    final updated = {
      ...existing,
      ...metadata,
      'trackId': trackId,
      'status': 'processing',
      'audioUrl': 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': 'https://mock.cdn/waveform/$trackId.json',
      'artworkUrl': artworkPath ?? existing['artworkUrl'],
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _tracks[trackId] = updated;
    return Map<String, dynamic>.from(updated);
  }

  Future<Map<String, dynamic>> pollTrackStatus({required String trackId}) async {
    await Future.delayed(const Duration(seconds: 2));
    final existing = _tracks[trackId] ?? {'trackId': trackId, 'createdAt': DateTime.now().toIso8601String()};
    final updated = {
      ...existing,
      'trackId': trackId,
      'status': 'finished',
      'audioUrl': existing['audioUrl'] ?? 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': existing['waveformUrl'] ?? 'https://mock.cdn/waveform/$trackId.json',
      'durationSeconds': existing['durationSeconds'] ?? 0,
      'audioMetadata': existing['audioMetadata'] ?? {
        'bitrateKbps': 320,
        'sampleRateHz': 44100,
        'format': 'mp3',
        'fileSizeBytes': 8388608,
      },
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _tracks[trackId] = updated;
    _persistToStore(updated);
    return Map<String, dynamic>.from(updated);
  }

  Future<Map<String, dynamic>> getTrackDetails({required String trackId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final existing = _tracks[trackId];
    if (existing == null) {
      return {'trackId': trackId, 'status': 'failed', 'error': {'code': 'NOT_FOUND', 'message': 'Track not found'}};
    }
    return Map<String, dynamic>.from(existing);
  }

  Future<void> deleteTrack({required String trackId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_tracks.containsKey(trackId)) {
      _tracks[trackId] = {..._tracks[trackId]!, 'status': 'deleted'};
    }
    GlobalTrackStore.instance.remove(trackId);
  }

  Future<Map<String, dynamic>> updateTrackMetadata({
    required String trackId,
    required Map<String, dynamic> metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existing = _tracks[trackId] ?? {'trackId': trackId, 'createdAt': DateTime.now().toIso8601String()};
    final artworkPath = metadata['artworkPath'] as String?;
    final updated = {
      ...existing,
      ...metadata,
      'trackId': trackId,
      'status': 'finished',
      'artworkUrl': artworkPath ?? existing['artworkUrl'],
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _tracks[trackId] = updated;
    _persistToStore(updated);
    return Map<String, dynamic>.from(updated);
  }

  // ── Private ──────────────────────────────────────────────────────────────

  void _persistToStore(Map<String, dynamic> data) {
    final trackId = data['trackId'] as String;
    final artists = (data['artists'] as List?)?.map((e) => e.toString()).toList() ?? ['Unknown'];
    final duration = (data['durationSeconds'] as int?) ?? 0;
    final localFilePath = _localFilePaths[trackId];
    final artworkUrl = data['artworkUrl'] as String?;
    // artworkUrl for local files IS the local path when set from finalizeMetadata

 final item = UploadItem(
  id: trackId,
  title: (data['title'] as String?)?.trim().isEmpty == true
      ? 'Untitled'
      : (data['title'] as String?) ?? 'Untitled',
  artistDisplay: artists.join(', '),
  durationLabel: _fmt(duration),
  durationSeconds: duration,
  audioUrl: data['audioUrl'] as String?,
  waveformUrl: data['waveformUrl'] as String?,
  artworkUrl: artworkUrl,
  localArtworkPath:
      (artworkUrl != null && !artworkUrl.startsWith('http')) ? artworkUrl : null,
  localFilePath: localFilePath,
  description: data['description'] as String?,
  tags: (data['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
  genreCategory: (data['genreCategory'] as String?) ?? '',
  genreSubGenre: (data['genreSubGenre'] as String?) ?? '',
  visibility: (data['privacy'] as String?) == 'public'
      ? UploadVisibility.public
      : UploadVisibility.private,
  status: ((data['status'] as String?) == 'processing' ||
          (data['status'] as String?) == 'uploading')
      ? UploadProcessingStatus.processing
      : UploadProcessingStatus.finished,
  isExplicit: (data['contentWarning'] as bool?) ?? false,
  recordLabel: (data['recordLabel'] as String?) ?? '',
  publisher: (data['publisher'] as String?) ?? '',
  isrc: (data['isrc'] as String?) ?? '',
  pLine: (data['pLine'] as String?) ?? '',
  scheduledReleaseDate:
      DateTime.tryParse(data['scheduledReleaseDate'] as String? ?? ''),
  allowDownloads: (data['allowDownloads'] as bool?) ?? false,
  offlineListening: (data['offlineListening'] as bool?) ?? true,
  includeInRss: (data['includeInRss'] as bool?) ?? true,
  displayEmbedCode: (data['displayEmbedCode'] as bool?) ?? true,
  appPlaybackEnabled: (data['appPlaybackEnabled'] as bool?) ?? true,
  availabilityType: (data['availabilityType'] as String?) ?? 'worldwide',
  availabilityRegions: (data['availabilityRegions'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
      const [],
  licensing: (data['licensing'] as String?) ?? 'all_rights_reserved',
  createdAt:
      DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
);

    GlobalTrackStore.instance.add(item);
  }

  static String _fmt(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
