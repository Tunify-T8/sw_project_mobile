import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/cloudinary_pending_track.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/cloudinary_upload_artwork_resolver.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/cloudinary_upload_mapper.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/cloudinary_media_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  void clearStore() {
    for (final item in GlobalTrackStore.instance.all.toList()) {
      GlobalTrackStore.instance.remove(item.id);
    }
  }

  setUp(clearStore);
  tearDown(clearStore);

  group('PendingCloudinaryTrack', () {
    test('maps from upload items and supports copyWith', () {
      final draft = PendingCloudinaryTrack.maybeFromUploadItem(sampleUploadItem);

      expect(draft, isNotNull);
      expect(draft?.trackId, 'track-1');
      expect(draft?.artists, ['Kevin']);
      expect(draft?.privacy, 'public');

      final updated = draft?.copyWith(
        title: 'Updated',
        privacy: 'private',
        waveformBars: const [0.1, 0.8],
      );
      expect(updated?.title, 'Updated');
      expect(updated?.privacy, 'private');
      expect(updated?.waveformBars, [0.1, 0.8]);
      expect(PendingCloudinaryTrack.maybeFromUploadItem(null), isNull);
    });
  });

  group('cloudinary upload mapper helpers', () {
    test('mapPendingTrackToUploadedTrack preserves user-facing fields', () {
      final draft = PendingCloudinaryTrack(
        trackId: 'track-1',
        createdAt: DateTime.utc(2026, 3, 1),
        audioUrl: 'https://cdn.example.com/audio.mp3',
        waveformUrl: 'https://cdn.example.com/wave.png',
        title: 'Midnight Echo',
        description: 'Synth demo',
        privacy: 'private',
        artworkUrl: 'https://cdn.example.com/art.png',
        durationSeconds: 245,
      );

      final track = mapPendingTrackToUploadedTrack(draft, UploadStatus.finished);

      expect(track.trackId, 'track-1');
      expect(track.status, UploadStatus.finished);
      expect(track.privacy, 'private');
      expect(track.durationSeconds, 245);
    });

    test('savePendingTrackToGlobalStore and helper functions map values correctly', () {
      final draft = PendingCloudinaryTrack(
        trackId: 'track-1',
        createdAt: DateTime.utc(2026, 3, 1),
        title: '  Midnight Echo  ',
        privacy: 'private',
        artists: const ['Kevin', 'Luna'],
        durationSeconds: 245,
        waveformBars: const [0.2, 0.5],
        contentWarning: true,
        availabilityRegions: const ['US', 'CA'],
      );

      savePendingTrackToGlobalStore(
        draft,
        status: UploadProcessingStatus.processing,
      );
      final stored = GlobalTrackStore.instance.find('track-1');

      expect(stored?.title, 'Midnight Echo');
      expect(stored?.artistDisplay, 'Kevin, Luna');
      expect(stored?.visibility, UploadVisibility.private);
      expect(stored?.status, UploadProcessingStatus.processing);
      expect(stored?.durationLabel, '4:05');
      expect(mapUploadProcessingStatus(UploadProcessingStatus.failed), UploadStatus.failed);
      expect(isRemoteCloudinaryAsset('https://cdn.example.com/file.png'), isTrue);
      expect(isRemoteCloudinaryAsset(r'C:\art\cover.png'), isFalse);
      expect(cloudinaryFileNameFromPath(r'C:\art\cover.png'), 'cover.png');
      expect(formatCloudinaryDuration(125), '2:05');
    });
  });

  group('cloudinary artwork resolver', () {
    late MockCloudinaryMediaService mockMediaService;

    setUp(() {
      mockMediaService = MockCloudinaryMediaService();
    });

    test('returns current artwork when the path is blank', () async {
      final result = await resolveCloudinaryArtwork(
        mediaService: mockMediaService,
        artworkPath: '   ',
        currentArtworkUrl: 'https://cdn.example.com/current.png',
        currentLocalArtworkPath: r'C:\art\old.png',
      );

      expect(result.artworkUrl, 'https://cdn.example.com/current.png');
      expect(result.localArtworkPath, r'C:\art\old.png');
      verifyNever(
        mockMediaService.uploadArtwork(
          filePath: anyNamed('filePath'),
          fileName: anyNamed('fileName'),
        ),
      );
    });

    test('keeps remote artwork paths without reuploading', () async {
      final result = await resolveCloudinaryArtwork(
        mediaService: mockMediaService,
        artworkPath: 'https://cdn.example.com/new.png',
        currentArtworkUrl: 'https://cdn.example.com/current.png',
        currentLocalArtworkPath: r'C:\art\old.png',
      );

      expect(result.artworkUrl, 'https://cdn.example.com/new.png');
      expect(result.localArtworkPath, r'C:\art\old.png');
    });

    test('uploads local artwork and applyCloudinaryTrackMetadata saves it on the draft', () async {
      when(
        mockMediaService.uploadArtwork(
          filePath: r'C:\art\cover.png',
          fileName: 'cover.png',
        ),
      ).thenAnswer(
        (_) async => const CloudinaryAsset(
          secureUrl: 'https://cdn.example.com/cover.png',
          publicId: 'art/cover',
          resourceType: 'image',
        ),
      );

      final artwork = await resolveCloudinaryArtwork(
        mediaService: mockMediaService,
        artworkPath: r'C:\art\cover.png',
        currentArtworkUrl: null,
        currentLocalArtworkPath: null,
      );
      final updated = applyCloudinaryTrackMetadata(
        PendingCloudinaryTrack(
          trackId: 'track-1',
          createdAt: DateTime.utc(2026, 3, 1),
        ),
        sampleTrackMetadata,
        artwork,
      );

      expect(artwork.artworkUrl, 'https://cdn.example.com/cover.png');
      expect(updated.title, 'Midnight Echo');
      expect(updated.artworkUrl, 'https://cdn.example.com/cover.png');
      expect(updated.localArtworkPath, r'C:\art\cover.png');
      expect(updated.availabilityRegions, isEmpty);
    });
  });
}
