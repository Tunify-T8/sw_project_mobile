import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_filter.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_state.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_metadata_mapper.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_metadata_state.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_state.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import 'helpers/upload_test_data.dart';

void main() {
  group('Module 4 quick coverage boost', () {
    test('addListener runs immediately when token is already cancelled', () {
      final token = UploadCancellationToken();
      var callCount = 0;

      token.cancel();
      token.addListener(() {
        callCount++;
      });

      expect(token.isCancelled, isTrue);
      expect(callCount, 1);
    });

    test('UploadedTrack.copyWith keeps original status when status is not passed', () {
      final updated = sampleUploadedTrack.copyWith(
        title: 'Updated title',
      );

      expect(updated.title, 'Updated title');
      expect(updated.status, sampleUploadedTrack.status);
      expect(updated.audioUrl, sampleUploadedTrack.audioUrl);
    });

    test('library uploads filter keeps only public items and sorts by track name', () {
      final zebra = sampleUploadItem.copyWith(
        id: 'track-z',
        title: 'Zebra Song',
        artistDisplay: 'Kevin',
        visibility: UploadVisibility.public,
        createdAt: DateTime.utc(2026, 3, 2),
      );

      final alpha = sampleUploadItem.copyWith(
        id: 'track-a',
        title: 'Alpha Song',
        artistDisplay: 'Kevin',
        visibility: UploadVisibility.public,
        createdAt: DateTime.utc(2026, 3, 3),
      );

      final hidden = sampleUploadItem.copyWith(
        id: 'track-hidden',
        title: 'Hidden Song',
        artistDisplay: 'Kevin',
        visibility: UploadVisibility.private,
        createdAt: DateTime.utc(2026, 3, 4),
      );

      final result = applyLibraryUploadsFilter(
        source: [zebra, hidden, alpha],
        query: '',
        sort: UploadSortOrder.trackName,
        visibility: UploadVisibilityFilter.public,
      );

      expect(result.map((item) => item.title).toList(), [
        'Alpha Song',
        'Zebra Song',
      ]);
    });

    test('TrackMetadataMapper keeps scheduled release date when scheduling is enabled', () {
      final state = TrackMetadataState(
        title: 'Release Track',
        artists: const ['Kevin'],
        hasScheduledRelease: true,
        scheduledReleaseDate: DateTime.utc(2026, 4, 1),
        availabilityType: 'worldwide',
      );

      final entity = TrackMetadataMapper.toEntity(state);

      expect(entity.scheduledReleaseDate, DateTime.utc(2026, 4, 1));
      expect(entity.availabilityRegions, isEmpty);
    });

    test('UploadState derived getters report busy and finished correctly', () {
      const busyState = UploadState(
        isPreparingUpload: true,
        hasUploadedAudio: true,
      );

      const finishedState = UploadState(
        hasUploadedAudio: true,
      );

      expect(busyState.isBusy, isTrue);
      expect(busyState.uploadFinished, isFalse);

      expect(finishedState.isBusy, isFalse);
      expect(finishedState.uploadFinished, isTrue);

      expect(const UploadCancelledException(), isA<UploadCancelledException>());
    });
  });
}