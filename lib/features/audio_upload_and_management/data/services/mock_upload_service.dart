import 'dart:async';
// redo

class MockUploadService {
  Future<Map<String, dynamic>> getUploadQuota() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'tier': 'free',
      'uploadMinutesRemaining': 176,
    };
  }

  Future<Map<String, dynamic>> createTrack() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'trackId': 'track_123',
      'status': 'idle',
    };
  }

  Stream<double> uploadFileProgress() async* {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      yield i / 10;
    }
  }

  Future<String> processTrack() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'finished';
  }
}