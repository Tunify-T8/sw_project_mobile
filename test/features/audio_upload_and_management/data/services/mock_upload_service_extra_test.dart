import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/mock_upload_defaults.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/mock_upload_service.dart';

void main() {
  group('MockUploadService extra coverage', () {
    late MockUploadService service;

    setUp(() {
      GlobalTrackStore.instance.clear();
      service = MockUploadService();
    });

    tearDown(() {
      GlobalTrackStore.instance.clear();
    });

    test('uploadProgress emits ten steps from 0.1 to 1.0', () async {
      final progressValues = await service.uploadProgress().toList();

      expect(progressValues, hasLength(10));
      expect(progressValues.first, 0.1);
      expect(progressValues.last, 1.0);
    });

    test('replaceAudio puts the track back into processing and clears generated media fields', () async {
      final created = await service.createTrack(userId: 'user-1');
      final trackId = created['trackId'] as String;

      await service.finalizeMetadata(
        trackId: trackId,
        metadata: {
          'title': 'Before replace',
          'description': 'Old metadata',
        },
      );

      final replaced = await service.replaceAudio(trackId: trackId);

      expect(replaced['status'], 'processing');
      expect(replaced['audioUrl'], isNull);
      expect(replaced['waveformUrl'], isNull);
      expect(replaced['durationSeconds'], isNull);
      expect(replaced['audioMetadata'], isNull);
    });
  });

  group('mock upload defaults helpers', () {
    test('mockTrackFallback creates a minimal fallback track record', () {
      final fallback = mockTrackFallback('missing-track');

      expect(fallback['trackId'], 'missing-track');
      expect(fallback['createdAt'], isA<String>());
    });
  });
}