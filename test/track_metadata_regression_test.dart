import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/finalize_track_metadata_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/track_response_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/mappers/upload_mappers.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_detail_item_provider.dart';

import 'features/audio_upload_and_management/helpers/upload_test_data.dart';

void main() {
  test('track details preserve editable metadata fields', () {
    final dto = TrackResponseDto.fromJson(
      sampleTrackResponseJson(status: 'finished'),
    );
    final entity = dto.toEntity();

    expect(entity.genreCategory, 'music');
    expect(entity.genreSubGenre, 'hiphop');
    expect(entity.scheduledReleaseDate, DateTime.utc(2026, 4, 1));
    expect(entity.allowDownloads, isFalse);
    expect(entity.offlineListening, isTrue);
    expect(entity.includeInRss, isTrue);
    expect(entity.displayEmbedCode, isTrue);
    expect(entity.appPlaybackEnabled, isTrue);
    expect(entity.licensing, 'creative_commons');
  });

  test(
    'nested backend genre objects are converted into edit-friendly values',
    () {
      final dto = TrackResponseDto.fromJson({
        'trackId': 'track-1',
        'status': 'finished',
        'genre': {'category': 'country', 'subGenre': null},
      });

      expect(dto.genreCategory, 'music');
      expect(dto.genreSubGenre, 'country');
      expect(dto.genre, 'music_country');
    },
  );

  test('saving without a selected genre does not force hiphop', () {
    final dto = FinalizeTrackMetadataRequestDto.fromEntity(
      trackId: 'track-1',
      metadata: const TrackMetadata(
        title: 'Midnight Echo',
        genreCategory: '',
        genreSubGenre: '',
        tags: [],
        description: 'Synth demo',
        privacy: 'public',
        artists: ['Kevin'],
        artworkPath: null,
      ),
    );

    expect(dto.genre, isEmpty);
    expect(dto.toJsonBody().containsKey('genre'), isFalse);
  });

  test('mergeTrackDetailItem hydrates edit metadata from track details', () {
    final merged = mergeTrackDetailItem(
      base: sampleUploadItem.copyWith(
        genreCategory: 'music',
        genreSubGenre: 'hiphop',
        scheduledReleaseDate: null,
        allowDownloads: false,
        offlineListening: true,
        includeInRss: true,
        displayEmbedCode: true,
        appPlaybackEnabled: true,
        licensing: 'all_rights_reserved',
      ),
      details: UploadedTrack(
        trackId: 'track-1',
        status: UploadStatus.finished,
        genreCategory: 'music',
        genreSubGenre: 'country',
        scheduledReleaseDate: DateTime.utc(2026, 6, 1),
        allowDownloads: true,
        offlineListening: false,
        includeInRss: false,
        displayEmbedCode: false,
        appPlaybackEnabled: false,
        licensing: 'creative_commons',
      ),
    );

    expect(merged.genreCategory, 'music');
    expect(merged.genreSubGenre, 'country');
    expect(merged.scheduledReleaseDate, DateTime.utc(2026, 6, 1));
    expect(merged.allowDownloads, isTrue);
    expect(merged.offlineListening, isFalse);
    expect(merged.includeInRss, isFalse);
    expect(merged.displayEmbedCode, isFalse);
    expect(merged.appPlaybackEnabled, isFalse);
    expect(merged.licensing, 'creative_commons');
  });

  test('mergeTrackDetailItem refreshes stale upload processing status', () {
    final merged = mergeTrackDetailItem(
      base: sampleUploadItem.copyWith(
        status: UploadProcessingStatus.processing,
      ),
      details: const UploadedTrack(
        trackId: 'track-1',
        status: UploadStatus.finished,
      ),
    );

    expect(merged.status, UploadProcessingStatus.finished);
    expect(merged.isPlayable, isTrue);
  });

  test(
    'mergeTrackDetailItem keeps private token when details token is blank',
    () {
      final merged = mergeTrackDetailItem(
        base: sampleUploadItem.copyWith(privateToken: 'existing-token'),
        details: const UploadedTrack(
          trackId: 'track-1',
          status: UploadStatus.finished,
          privateToken: '  ',
        ),
      );

      expect(merged.privateToken, 'existing-token');
    },
  );
}
