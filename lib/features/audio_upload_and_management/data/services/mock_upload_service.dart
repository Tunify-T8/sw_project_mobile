// Upload Feature Guide:
// Purpose: Local in-memory upload engine used to simulate draft creation, upload progress, processing, metadata save, and delete.
// Used by: mock_upload_repository_impl, upload_repository_provider
// Concerns: Multi-format support.
import 'dart:async';

import 'global_track_store.dart';
import 'mock_upload_defaults.dart';
import 'mock_upload_store_mapper.dart';
import 'upload_waveform_service.dart';

class MockUploadService {
  final Map<String, Map<String, dynamic>> _tracks = {};
  final Map<String, String> _localFilePaths = {};
  final UploadWaveformService _waveformService = UploadWaveformService();

  Future<Map<String, dynamic>> getUploadQuota({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final usedMinutes = GlobalTrackStore.instance.usedUploadMinutesForUser(
      userId,
    );
    final remainingMinutes = usedMinutes >= 180 ? 0 : 180 - usedMinutes;

    return {
      'tier': 'free',
      'uploadMinutesLimit': 180,
      'uploadMinutesUsed': usedMinutes,
      'uploadMinutesRemaining': remainingMinutes,
      'canReplaceFiles': false,
      'canScheduleRelease': false,
      'canAccessAdvancedTab': false,
    };
  }

  Future<Map<String, dynamic>> createTrack({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final trackId = 'track_${DateTime.now().millisecondsSinceEpoch}';
    final track = createMockTrackRecord(trackId, ownerUserId: userId);
    _tracks[trackId] = track;
    return Map<String, dynamic>.from(track);
  }

  Stream<double> uploadProgress() async* {
    for (var step = 1; step <= 10; step++) {
      await Future.delayed(const Duration(milliseconds: 250));
      yield step / 10;
    }
  }

  Future<Map<String, dynamic>> uploadAudio({
    required String trackId,
    String? localFilePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (localFilePath != null) _localFilePaths[trackId] = localFilePath;
    return _mergeTrack(trackId, {
      'status': 'uploading',
      'audioUrl': null,
      'waveformUrl': null,
    });
  }

  Future<Map<String, dynamic>> replaceAudio({required String trackId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mergeTrack(trackId, {
      'status': 'processing',
      'audioUrl': null,
      'waveformUrl': null,
      'durationSeconds': null,
      'audioMetadata': null,
    });
  }

  Future<Map<String, dynamic>> finalizeMetadata({
    required String trackId,
    required Map<String, dynamic> metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mergeTrack(trackId, {
      ...metadata,
      'status': 'processing',
      'audioUrl': 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': 'https://mock.cdn/waveform/$trackId.json',
      'artworkUrl':
          metadata['artworkPath'] ?? _currentTrack(trackId)['artworkUrl'],
    });
  }

  Future<Map<String, dynamic>> pollTrackStatus({
    required String trackId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final current = _currentTrack(trackId);
    final waveformBars = await _buildWaveformBars(trackId);
    final updated = await _mergeTrack(trackId, {
      'status': 'finished',
      'audioUrl': current['audioUrl'] ?? 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl':
          current['waveformUrl'] ?? 'https://mock.cdn/waveform/$trackId.json',
      'waveformBars': waveformBars ?? current['waveformBars'],
      'durationSeconds': current['durationSeconds'] ?? 0,
      'audioMetadata':
          current['audioMetadata'] ??
          {
            'bitrateKbps': 320,
            'sampleRateHz': 44100,
            'format': 'mp3',
            'fileSizeBytes': 8388608,
          },
    });
    persistMockTrackToStore(updated, _localFilePaths);
    return updated;
  }

  Future<Map<String, dynamic>> getTrackDetails({
    required String trackId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final existing = _tracks[trackId];
    if (existing == null) {
      return {
        'trackId': trackId,
        'status': 'failed',
        'error': {'code': 'NOT_FOUND', 'message': 'Track not found'},
      };
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
    final waveformBars = await _buildWaveformBars(trackId);
    final updated = await _mergeTrack(trackId, {
      ...metadata,
      'status': 'finished',
      'artworkUrl':
          metadata['artworkPath'] ?? _currentTrack(trackId)['artworkUrl'],
      'waveformBars': waveformBars ?? _currentTrack(trackId)['waveformBars'],
    });
    persistMockTrackToStore(updated, _localFilePaths);
    return updated;
  }

  Map<String, dynamic> _currentTrack(String trackId) =>
      _tracks[trackId] ?? mockTrackFallback(trackId);

  Future<Map<String, dynamic>> _mergeTrack(
    String trackId,
    Map<String, dynamic> updates,
  ) async {
    final updated = {
      ..._currentTrack(trackId),
      'trackId': trackId,
      ...updates,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _tracks[trackId] = updated;
    return Map<String, dynamic>.from(updated);
  }

  Future<List<double>?> _buildWaveformBars(String trackId) async {
    final localFilePath = _localFilePaths[trackId]?.trim();
    if (localFilePath == null || localFilePath.isEmpty) {
      return null;
    }
    return _waveformService.generateDisplayBarsFromFile(localFilePath);
  }
}
