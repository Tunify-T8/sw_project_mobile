import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/mock_library_uploads_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/mock_upload_service.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  void clearStore() {
    GlobalTrackStore.instance.clear();
  }

  Map<String, dynamic> metadata({
    String title = 'Midnight Echo',
    String privacy = 'private',
    String? artworkPath,
  }) {
    return {
      'title': title,
      'genreCategory': 'music',
      'genreSubGenre': 'hiphop',
      'tags': ['night', 'beats'],
      'description': 'Synth demo',
      'privacy': privacy,
      'artists': ['Kevin'],
      'artworkPath': artworkPath,
      'recordLabel': 'Night Records',
      'publisher': 'Moon Publishing',
      'isrc': 'US-S1Z-99-00001',
      'pLine': '2026 Night Records',
      'contentWarning': false,
      'scheduledReleaseDate': '2026-04-01T00:00:00.000Z',
      'allowDownloads': true,
      'offlineListening': false,
      'includeInRss': false,
      'displayEmbedCode': false,
      'appPlaybackEnabled': false,
      'availabilityType': 'exclusive_regions',
      'availabilityRegions': ['US', 'CA'],
      'licensing': 'creative_commons',
    };
  }

  setUp(clearStore);
  tearDown(clearStore);

  group('MockUploadService', () {
    late MockUploadService service;

    setUp(() {
      service = MockUploadService();
    });

    test('returns a free upload quota', () async {
      final quota = await service.getUploadQuota(userId: 'user-1');

      expect(quota['tier'], 'free');
      expect(quota['uploadMinutesRemaining'], 180);
      expect(quota['canReplaceFiles'], isFalse);
    });

    test('creates a blank draft and returns it from track details', () async {
      final created = await service.createTrack(userId: 'user-1');
      final details = await service.getTrackDetails(
        trackId: created['trackId'] as String,
      );

      expect(created['status'], 'idle');
      expect(details['trackId'], created['trackId']);
      expect(details['artists'], ['ROZANA AHMED']);
      expect(details['privacy'], 'public');
    });

    test(
      'upload finalize poll and update persist track data into the global store',
      () async {
        final created = await service.createTrack(userId: 'user-1');
        final trackId = created['trackId'] as String;

        final uploading = await service.uploadAudio(
          trackId: trackId,
          localFilePath: r'C:\music\track.mp3',
        );
        final processing = await service.finalizeMetadata(
          trackId: trackId,
          metadata: metadata(artworkPath: r'C:\art\cover.png'),
        );
        final finished = await service.pollTrackStatus(trackId: trackId);
        final updated = await service.updateTrackMetadata(
          trackId: trackId,
          metadata: metadata(title: 'Updated Title', privacy: 'public'),
        );
        final stored = GlobalTrackStore.instance.find(trackId);

        expect(uploading['status'], 'uploading');
        expect(processing['status'], 'processing');
        expect(finished['status'], 'finished');
        expect(updated['title'], 'Updated Title');
        expect(stored, isNotNull);
        expect(stored?.title, 'Updated Title');
        expect(stored?.localFilePath, r'C:\music\track.mp3');
        expect(stored?.visibility, UploadVisibility.public);
        expect(stored?.allowDownloads, isTrue);
        expect(stored?.offlineListening, isFalse);
        expect(stored?.availabilityRegions, ['US', 'CA']);
        expect(stored?.licensing, 'creative_commons');
      },
    );

    test(
      'returns a failed response for unknown track details and delete removes stored items',
      () async {
        final missing = await service.getTrackDetails(trackId: 'missing');
        final created = await service.createTrack(userId: 'user-1');
        final trackId = created['trackId'] as String;
        await service.finalizeMetadata(
          trackId: trackId,
          metadata: metadata(title: 'Stored'),
        );
        await service.pollTrackStatus(trackId: trackId);

        expect(missing['status'], 'failed');
        expect((missing['error'] as Map<String, dynamic>)['code'], 'NOT_FOUND');

        await service.deleteTrack(trackId: trackId);
        expect(GlobalTrackStore.instance.find(trackId), isNull);
      },
    );
  });

  group('MockLibraryUploadsApi', () {
    late MockLibraryUploadsApi api;
    late MockTokenStorage mockTokenStorage;

    setUp(() {
      mockTokenStorage = MockTokenStorage();
      when(mockTokenStorage.getUser()).thenAnswer((_) async => null);
      api = MockLibraryUploadsApi(tokenStorage: mockTokenStorage);
      GlobalTrackStore.instance.add(
        UploadItem(
          id: 'track-1',
          title: 'Public Song',
          artistDisplay: 'Kevin',
          durationLabel: '1:00',
          durationSeconds: 60,
          artworkUrl: null,
          visibility: UploadVisibility.public,
          status: UploadProcessingStatus.finished,
          isExplicit: false,
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );
      GlobalTrackStore.instance.add(
        UploadItem(
          id: 'track-2',
          title: 'Deleted Song',
          artistDisplay: 'Kevin',
          durationLabel: '1:00',
          durationSeconds: 60,
          artworkUrl: null,
          visibility: UploadVisibility.private,
          status: UploadProcessingStatus.deleted,
          isExplicit: false,
          createdAt: DateTime.utc(2026, 1, 2),
        ),
      );
    });

    test(
      'returns only non-deleted uploads and the artist tools quota',
      () async {
        final uploads = await api.getMyUploads();
        final quota = await api.getArtistToolsQuota();

        expect(uploads, hasLength(1));
        expect(uploads.single.id, 'track-1');
        expect(quota.uploadMinutesLimit - quota.uploadMinutesUsed, 179);
        expect(quota.canUpgrade, isTrue);
      },
    );

    test('replace update and delete mutate the global store', () async {
      await api.replaceUploadFile(
        trackId: 'track-1',
        filePath: r'C:\music\replacement.mp3',
      );
      expect(
        GlobalTrackStore.instance.find('track-1')?.status,
        UploadProcessingStatus.processing,
      );
      expect(
        GlobalTrackStore.instance.find('track-1')?.localFilePath,
        r'C:\music\replacement.mp3',
      );

      final updated = await api.updateUpload(
        trackId: 'track-1',
        title: 'Updated',
        description: 'Updated description',
        privacy: 'private',
        localArtworkPath: r'C:\art\new.png',
      );
      expect(updated.title, 'Updated');
      expect(updated.privacy, 'private');
      expect(
        GlobalTrackStore.instance.find('track-1')?.artworkUrl,
        r'C:\art\new.png',
      );

      await api.deleteUpload('track-1');
      expect(GlobalTrackStore.instance.find('track-1'), isNull);
    });

    test(
      'throws a friendly exception when update targets a missing track',
      () async {
        await api.deleteUpload('track-1');

        expect(
          api.updateUpload(
            trackId: 'track-1',
            title: 'Updated',
            description: 'Updated description',
            privacy: 'public',
          ),
          throwsA(
            isA<UploadFlowException>().having(
              (error) => error.message,
              'message',
              'We could not find that track anymore. Please refresh and try again.',
            ),
          ),
        );
      },
    );

    test(
      'returns only the signed-in user uploads when a session exists',
      () async {
        final mockTokenStorage = MockTokenStorage();
        final scopedApi = MockLibraryUploadsApi(tokenStorage: mockTokenStorage);

        when(mockTokenStorage.getUser()).thenAnswer(
          (_) async => const AuthUserEntity(
            id: 'user-1',
            email: 'user1@test.com',
            username: 'User One',
            role: 'ARTIST',
            isVerified: true,
          ),
        );

        GlobalTrackStore.instance.clear();
        GlobalTrackStore.instance.add(
          UploadItem(
            id: 'track-a',
            title: 'Mine',
            artistDisplay: 'User One',
            durationLabel: '1:00',
            durationSeconds: 60,
            artworkUrl: null,
            visibility: UploadVisibility.public,
            status: UploadProcessingStatus.finished,
            isExplicit: false,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          ownerUserId: 'user-1',
        );
        GlobalTrackStore.instance.add(
          UploadItem(
            id: 'track-b',
            title: 'Not Mine',
            artistDisplay: 'User Two',
            durationLabel: '1:00',
            durationSeconds: 60,
            artworkUrl: null,
            visibility: UploadVisibility.public,
            status: UploadProcessingStatus.finished,
            isExplicit: false,
            createdAt: DateTime.utc(2026, 1, 2),
          ),
          ownerUserId: 'user-2',
        );

        final uploads = await scopedApi.getMyUploads();

        expect(uploads, hasLength(1));
        expect(uploads.single.id, 'track-a');
      },
    );
  });
}
