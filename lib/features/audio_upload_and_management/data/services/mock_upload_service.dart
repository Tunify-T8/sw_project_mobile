import 'dart:async';

class MockUploadService {
  Future<Map<String, dynamic>> getUploadQuota({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'tier': 'free',
      'uploadMinutesLimit': 180,
      'uploadMinutesUsed': 4,
      'uploadMinutesRemaining': 176,
      'canUpgrade': true,
    };
  }

  Future<Map<String, dynamic>> createTrack({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'trackId': 'track_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'idle',
      'audioUrl': null,
      'waveformUrl': null,
    };
  }

  Stream<double> uploadProgress() async* {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      yield i / 10;
    }
  }

  Future<String> processTrack() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'finished';
  }

  Future<Map<String, dynamic>> uploadAudio({required String trackId}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'trackId': trackId,
      'status': 'uploading',
      'audioUrl': null,
      'waveformUrl': null,
    };
  }

  Future<Map<String, dynamic>> finalizeMetadata({
    required String trackId,
    required Map<String, dynamic> metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'trackId': trackId,
      'status': 'processing',
      'audioUrl': 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': 'https://mock.cdn/waveform/$trackId.json',
      'title': metadata['title'],
      'description': metadata['description'],
      'privacy': metadata['privacy'],
      'artworkUrl': metadata['artworkPath'] != null
          ? 'https://mock.cdn/artwork/$trackId.png'
          : null,
    };
  }

  Future<Map<String, dynamic>> pollTrackStatus({
    required String trackId,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return {
      'trackId': trackId,
      'status': 'finished',
      'audioUrl': 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': 'https://mock.cdn/waveform/$trackId.json',
      'artworkUrl': 'https://mock.cdn/artwork/$trackId.png',
    };
  }

  Future<Map<String, dynamic>> getTrackDetails({
    required String trackId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'trackId': trackId,
      'status': 'finished',
      'audioUrl': 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': 'https://mock.cdn/waveform/$trackId.json',
      'artworkUrl': 'https://mock.cdn/artwork/$trackId.png',
    };
  }
}
