import 'dart:async';
// “Pretend a backend exists, but we’re just simulating it with delays and mock data. This allows us to test our frontend logic without needing a real server.”
// return fake raw data
// simulate delay
// simulate progress
// simulate processing

// service = source of raw data
// repository = domain-facing wrapper

class MockUploadService {
  Future<Map<String, dynamic>> getUploadQuota({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'tier': 'free',
      'uploadMinutesLimit': 180,
      'uploadMinutesUsed': 4,
      'uploadMinutesRemaining': 176,
      'canReplaceFiles': false,
      'canScheduleRelease': false,
      'canAccessAdvancedTab': false,
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
      'recordLabel': metadata['recordLabel'],
      'publisher': metadata['publisher'],
      'isrc': metadata['isrc'],
      'contentWarning': metadata['contentWarning'],
      'scheduledReleaseDate': metadata['scheduledReleaseDate'],
      'allowDownloads': metadata['allowDownloads'],
      'offlineListening': metadata['offlineListening'],
      'includeInRss': metadata['includeInRss'],
      'displayEmbedCode': metadata['displayEmbedCode'],
      'appPlaybackEnabled': metadata['appPlaybackEnabled'],
      'availabilityType': metadata['availabilityType'],
      'availabilityRegions': metadata['availabilityRegions'],
      'licensing': metadata['licensing'],
    };
  }

  Future<Map<String, dynamic>> updateTrackMetadata({
    required String trackId,
    required Map<String, dynamic> metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'trackId': trackId,
      'status': 'finished',
      'audioUrl': 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': 'https://mock.cdn/waveform/$trackId.json',
      'title': metadata['title'],
      'description': metadata['description'],
      'privacy': metadata['privacy'],
      'artworkUrl': metadata['artworkPath'] != null
          ? 'https://mock.cdn/artwork/$trackId.png'
          : null,
      'recordLabel': metadata['recordLabel'],
      'publisher': metadata['publisher'],
      'isrc': metadata['isrc'],
      'contentWarning': metadata['contentWarning'],
      'scheduledReleaseDate': metadata['scheduledReleaseDate'],
      'allowDownloads': metadata['allowDownloads'],
      'offlineListening': metadata['offlineListening'],
      'includeInRss': metadata['includeInRss'],
      'displayEmbedCode': metadata['displayEmbedCode'],
      'appPlaybackEnabled': metadata['appPlaybackEnabled'],
      'availabilityType': metadata['availabilityType'],
      'availabilityRegions': metadata['availabilityRegions'],
      'licensing': metadata['licensing'],
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
      'title': 'My Awesome Track',
      'description': 'This is my new track',
      'privacy': 'public',
      'audioUrl': 'https://mock.cdn/audio/$trackId.mp3',
      'waveformUrl': 'https://mock.cdn/waveform/$trackId.json',
      'artworkUrl': 'https://mock.cdn/artwork/$trackId.png',
      'durationSeconds': 245,
    };
  }

  Future<void> deleteTrack({required String trackId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

  // if backend is late lets put the audio uploaded into the assets to play it locally, and then when the backend is ready we can switch to the real URL. this way we can test the full flow without needing a real backend yet.


  //A more advanced mock could have returned:
  //processing first time
  //processing second time
  //finished third time