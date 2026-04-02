import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_state.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../helpers/local_upload_test_mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
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

  test('load populates uploads, filtered list, and quota', () async {
    final publicItem = sampleUploadItem;
    final privateItem = sampleUploadItem.copyWith(
      id: 'track-2',
      title: 'After Hours',
      artistDisplay: 'Luna',
      visibility: UploadVisibility.private,
      createdAt: DateTime.utc(2026, 2, 1),
    );
    when(
      mockGetMyUploads.call(),
    ).thenAnswer((_) async => [publicItem, privateItem]);
    when(
      mockGetArtistToolsQuota.call(),
    ).thenAnswer((_) async => sampleArtistToolsQuota);

    final container = buildContainer();
    addTearDown(container.dispose);

    await container.read(libraryUploadsProvider.notifier).load();
    final state = container.read(libraryUploadsProvider);

    expect(state.items.length, 2);
    expect(state.filteredItems.length, 2);
    expect(state.quota?.tier, sampleArtistToolsQuota.tier);
    expect(
      state.quota?.uploadMinutesRemaining,
      sampleArtistToolsQuota.uploadMinutesRemaining,
    );
    expect(state.isLoading, isFalse);
  });

  test('load stores a friendly error when fetching fails', () async {
    when(
      mockGetMyUploads.call(),
    ).thenThrow(const UploadFlowException('Broken upload feed.'));

    final container = buildContainer();
    addTearDown(container.dispose);

    await container.read(libraryUploadsProvider.notifier).load();

    expect(container.read(libraryUploadsProvider).error, 'Broken upload feed.');
  });

  test('query, sorting, and visibility filter update filteredItems immediately', () async {
    final publicItem = sampleUploadItem;
    final privateItem = sampleUploadItem.copyWith(
      id: 'track-2',
      title: 'After Hours',
      artistDisplay: 'Luna',
      visibility: UploadVisibility.private,
      createdAt: DateTime.utc(2026, 2, 1),
    );
    when(
      mockGetMyUploads.call(),
    ).thenAnswer((_) async => [publicItem, privateItem]);
    when(
      mockGetArtistToolsQuota.call(),
    ).thenAnswer((_) async => sampleArtistToolsQuota);

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(libraryUploadsProvider.notifier);

    await notifier.load();
    notifier.setQuery('luna');
    expect(container.read(libraryUploadsProvider).filteredItems, [privateItem]);

    notifier.setQuery('');
    notifier.setVisibilityFilter(UploadVisibilityFilter.public);
    expect(container.read(libraryUploadsProvider).filteredItems, [publicItem]);

    notifier.setVisibilityFilter(UploadVisibilityFilter.all);
    notifier.setSortOrder(UploadSortOrder.firstAdded);
    expect(container.read(libraryUploadsProvider).filteredItems.first, privateItem);
  });

  test('deleteTrack removes the track from state on success', () async {
    when(mockDeleteUpload.call('track-1')).thenAnswer((_) async {});

    final container = buildContainer();
    addTearDown(container.dispose);
    container.read(libraryUploadsProvider.notifier).state = LibraryUploadsState(
      items: [sampleUploadItem],
      filteredItems: [sampleUploadItem],
    );

    await container.read(libraryUploadsProvider.notifier).deleteTrack('track-1');

    final state = container.read(libraryUploadsProvider);
    expect(state.items, isEmpty);
    expect(state.filteredItems, isEmpty);
    expect(state.busyTrackId, isNull);
  });

  test('replaceFile refreshes and clears busy state on success', () async {
    when(
      mockReplaceFile.call(trackId: 'track-1', filePath: '/tmp/new.mp3'),
    ).thenAnswer((_) async {});
    when(
      mockGetMyUploads.call(),
    ).thenAnswer((_) async => [sampleUploadItem]);
    when(
      mockGetArtistToolsQuota.call(),
    ).thenAnswer((_) async => sampleArtistToolsQuota);

    final container = buildContainer();
    addTearDown(container.dispose);

    await container.read(
      libraryUploadsProvider.notifier,
    ).replaceFile(trackId: 'track-1', filePath: '/tmp/new.mp3');

    final state = container.read(libraryUploadsProvider);
    expect(state.busyTrackId, isNull);
    verify(
      mockReplaceFile.call(trackId: 'track-1', filePath: '/tmp/new.mp3'),
    ).called(1);
  });

  test('updateTrack stores a friendly error when updating fails', () async {
    when(
      mockUpdateUpload.call(
        trackId: 'track-1',
        title: 'Updated',
        description: 'Updated description',
        privacy: 'private',
        localArtworkPath: null,
      ),
    ).thenThrow(const UploadFlowException('Could not update.'));

    final container = buildContainer();
    addTearDown(container.dispose);

    await container.read(libraryUploadsProvider.notifier).updateTrack(
      trackId: 'track-1',
      title: 'Updated',
      description: 'Updated description',
      privacy: 'private',
    );

    final state = container.read(libraryUploadsProvider);
    expect(state.error, 'Could not update.');
    expect(state.busyTrackId, isNull);
  });
}
