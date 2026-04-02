import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/mock_upload_service.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_state.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import 'helpers/local_upload_test_mocks.dart';
import 'helpers/upload_test_data.dart';

void main() {
  group('Upload coverage buffer - library uploads provider', () {
    late MockGetMyUploadsUsecase mockGetMyUploads;
    late MockGetArtistToolsQuotaUsecase mockGetArtistToolsQuota;
    late MockDeleteUploadUsecase mockDeleteUpload;
    late MockReplaceFileUsecase mockReplaceFile;
    late MockUpdateUploadUsecase mockUpdateUpload;

    ProviderContainer buildContainer() {
      return ProviderContainer(
        overrides: [
          getMyUploadsUsecaseProvider.overrideWithValue(mockGetMyUploads),
          getArtistToolsQuotaUsecaseProvider.overrideWithValue(
            mockGetArtistToolsQuota,
          ),
          deleteUploadUsecaseProvider.overrideWithValue(mockDeleteUpload),
          replaceFileUsecaseProvider.overrideWithValue(mockReplaceFile),
          updateUploadUsecaseProvider.overrideWithValue(mockUpdateUpload),
        ],
      );
    }

    setUp(() {
      mockGetMyUploads = MockGetMyUploadsUsecase();
      mockGetArtistToolsQuota = MockGetArtistToolsQuotaUsecase();
      mockDeleteUpload = MockDeleteUploadUsecase();
      mockReplaceFile = MockReplaceFileUsecase();
      mockUpdateUpload = MockUpdateUploadUsecase();
    });

    test(
      'refresh stores a friendly error and resets refreshing state on failure',
      () async {
        when(
          mockGetMyUploads.call(),
        ).thenThrow(const UploadFlowException('Refresh failed.'));

        final container = buildContainer();
        addTearDown(container.dispose);

        await container.read(libraryUploadsProvider.notifier).refresh();

        final state = container.read(libraryUploadsProvider);
        expect(state.error, 'Refresh failed.');
        expect(state.isRefreshing, isFalse);
      },
    );

    test(
      'deleteTrack stores a friendly error and clears busy state on failure',
      () async {
        when(
          mockDeleteUpload.call('track-1'),
        ).thenThrow(const UploadFlowException('Delete failed.'));

        final container = buildContainer();
        addTearDown(container.dispose);

        container
            .read(libraryUploadsProvider.notifier)
            .state = LibraryUploadsState(
          items: [sampleUploadItem],
          filteredItems: [sampleUploadItem],
        );

        await container
            .read(libraryUploadsProvider.notifier)
            .deleteTrack('track-1');

        final state = container.read(libraryUploadsProvider);
        expect(state.error, 'Delete failed.');
        expect(state.busyTrackId, isNull);
        expect(state.items, [sampleUploadItem]);
      },
    );

    test(
      'replaceFile stores a friendly error and clears busy state on failure',
      () async {
        when(
          mockReplaceFile.call(trackId: 'track-1', filePath: '/tmp/new.mp3'),
        ).thenThrow(const UploadFlowException('Replace failed.'));

        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(libraryUploadsProvider.notifier)
            .replaceFile(trackId: 'track-1', filePath: '/tmp/new.mp3');

        final state = container.read(libraryUploadsProvider);
        expect(state.error, 'Replace failed.');
        expect(state.busyTrackId, isNull);
      },
    );

    test(
      'updateTrack refreshes uploads and clears busy state on success',
      () async {
        when(
          mockGetMyUploads.call(),
        ).thenAnswer((_) async => [sampleUploadItem]);
        when(
          mockGetArtistToolsQuota.call(),
        ).thenAnswer((_) async => sampleArtistToolsQuota);
        when(
          mockUpdateUpload.call(
            trackId: 'track-1',
            title: 'Updated',
            description: 'Updated description',
            privacy: 'private',
            localArtworkPath: null,
          ),
        ).thenAnswer((_) async => sampleUploadItem);
        final container = buildContainer();
        addTearDown(container.dispose);

        await container
            .read(libraryUploadsProvider.notifier)
            .updateTrack(
              trackId: 'track-1',
              title: 'Updated',
              description: 'Updated description',
              privacy: 'private',
            );

        final state = container.read(libraryUploadsProvider);
        expect(state.busyTrackId, isNull);
        expect(state.items, [sampleUploadItem]);
        expect(state.quota?.tier, sampleArtistToolsQuota.tier);
      },
    );
  });

  group('Upload coverage buffer - simple upload units', () {
    test('GlobalTrackStore counts upload minutes from the local list', () {
      GlobalTrackStore.instance.clear();
      addTearDown(() => GlobalTrackStore.instance.clear());

      GlobalTrackStore.instance.add(
        sampleUploadItem.copyWith(id: 'track-1', durationSeconds: 61),
        ownerUserId: 'user-1',
      );
      GlobalTrackStore.instance.add(
        sampleUploadItem.copyWith(id: 'track-2', durationSeconds: 120),
        ownerUserId: 'user-1',
      );

      expect(GlobalTrackStore.instance.usedUploadMinutesForUser('user-1'), 4);
    });

    test('UploadItem getters and equality are based on status and id', () {
      final deleted = sampleUploadItem.copyWith(
        status: UploadProcessingStatus.deleted,
      );
      final sameIdDifferentFields = sampleUploadItem.copyWith(
        title: 'Completely Different Title',
        status: UploadProcessingStatus.processing,
      );
      final differentId = sampleUploadItem.copyWith(id: 'track-2');

      expect(sampleUploadItem.isPlayable, isTrue);
      expect(deleted.isDeleted, isTrue);
      expect(deleted.isPlayable, isFalse);

      expect(sampleUploadItem, sameIdDifferentFields);
      expect(sampleUploadItem.hashCode, sameIdDifferentFields.hashCode);
      expect(sampleUploadItem == differentId, isFalse);
    });

    test(
      'GlobalTrackStore can clear one owner without affecting another owner',
      () {
        GlobalTrackStore.instance.clear();
        addTearDown(() => GlobalTrackStore.instance.clear());

        final first = sampleUploadItem.copyWith(id: 'track-1', title: 'First');
        final second = sampleUploadItem.copyWith(
          id: 'track-2',
          title: 'Second',
        );

        GlobalTrackStore.instance.add(first, ownerUserId: 'user-1');
        GlobalTrackStore.instance.add(second, ownerUserId: 'user-2');

        expect(
          GlobalTrackStore.instance.ownerUserIdForTrack('track-1'),
          'user-1',
        );
        expect(
          GlobalTrackStore.instance.ownerUserIdForTrack('track-2'),
          'user-2',
        );

        GlobalTrackStore.instance.clear(ownerUserId: 'user-1');

        expect(GlobalTrackStore.instance.allForUser('user-1'), isEmpty);
        expect(
          GlobalTrackStore.instance.ownerUserIdForTrack('track-1'),
          isNull,
        );
        expect(
          GlobalTrackStore.instance
              .allForUser('user-2')
              .map((item) => item.id)
              .toList(),
          ['track-2'],
        );
      },
    );

    test('mockUploadServiceProvider builds the upload mock service', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(mockUploadServiceProvider),
        isA<MockUploadService>(),
      );
    });
  });
}
