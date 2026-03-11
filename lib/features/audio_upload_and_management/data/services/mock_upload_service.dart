import 'dart:async';

class MockUploadService {
  Future<Map<String, dynamic>> getUploadQuota() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'tier': 'free',
      'uploadMinutesRemaining': 176,
    };
  }

  Future<Map<String, dynamic>> createTrack({
    required String fileName}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return {
      'trackId': 'track_${DateTime.now().millisecondsSinceEpoch}',
      'status': 'idle',
      'originalFileName': fileName,
    };
  }

  Stream<double> uploadFileProgress() async* {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      yield i / 10;
    }
  }

  Future<String> processTrack() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'finished';
  }

  Future<void> finalizeMetadata({
    required String trackId,
    required String title,
    required String genre,
    required String description,
    required String tags,
    required String privacy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}