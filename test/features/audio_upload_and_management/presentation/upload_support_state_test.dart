import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/artist_tools_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/library_uploads_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/library_uploads_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/artist_tools_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_genre.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/delete_upload_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_artist_tools_quota_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_my_uploads_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/replace_file_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/search_my_uploads_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/update_upload_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_filter.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_state.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_metadata_mapper.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_metadata_state.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_metadata_validator.dart';

import '../helpers/local_upload_test_mocks.dart'
    show MockDio, MockMockLibraryUploadsApi;
import '../helpers/upload_test_data.dart';

void main() {
  test('artist tools quota entity exposes derived getters', () {
    const quota = ArtistToolsQuota(
      tier: ArtistTier.artist,
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 30,
      canReplaceFiles: true,
      canUpgrade: false,
    );

    expect(quota.uploadMinutesRemaining, 150);
    expect(quota.isFree, isFalse);
    expect(quota.canAmplify, isTrue);
  });

  test('artist tools quota dto parses defaults and serializes back to json', () {
    final dto = ArtistToolsQuotaDto.fromJson(const {});

    expect(dto.tier, 'free');
    expect(dto.uploadMinutesLimit, 180);
    expect(dto.uploadMinutesUsed, 0);
    expect(dto.canReplaceFiles, isFalse);
    expect(dto.canUpgrade, isTrue);
    expect(dto.toJson()['tier'], 'free');
  });

  test('track metadata state getters copyWith mapper and validator cover save rules', () {
    final state = TrackMetadataState(
      title: '  Midnight Echo  ',
      genreCategory: 'music',
      genreSubGenre: 'hiphop',
      tagsText: ' night, beats , ',
      description: '  Synth demo  ',
      artists: const [' Kevin ', '  '],
      artworkPath: ' cover.png ',
      hasScheduledRelease: false,
      scheduledReleaseDate: DateTime.utc(2026, 4, 1),
      availabilityType: 'exclusive_regions',
      availabilityRegionsText: 'us, ca',
      isSaving: true,
      processingStatus: UploadStatus.processing,
      error: 'old',
    );
    final mapped = TrackMetadataMapper.toEntity(state);
    final copied = state.copyWith(
      title: 'Updated',
      hasScheduledRelease: true,
      contentWarning: true,
      error: null,
    );

    expect(state.selectedGenre.subGenre, 'hiphop');
    expect(state.hasTitle, isTrue);
    expect(state.hasGenre, isTrue);
    expect(state.hasArtwork, isTrue);
    expect(state.hasDescription, isTrue);
    expect(state.completedChecklistItems, 4);
    expect(state.checklistProgress, 1);
    expect(state.isBusyInBackground, isTrue);
    expect(mapped.title, 'Midnight Echo');
    expect(mapped.tags, ['night', 'beats']);
    expect(mapped.artists, ['Kevin']);
    expect(mapped.availabilityRegions, ['US', 'CA']);
    expect(mapped.scheduledReleaseDate, isNull);
    expect(copied.title, 'Updated');
    expect(copied.contentWarning, isTrue);
    expect(copied.error, isNull);

    expect(
      TrackMetadataValidator.validateForSave(const TrackMetadataState()),
      'Title is required.',
    );
    expect(
      TrackMetadataValidator.validateForSave(
        const TrackMetadataState(title: 'Title', artists: ['   ']),
      ),
      'At least one artist is required.',
    );
    expect(
      TrackMetadataValidator.validateForSave(
        const TrackMetadataState(title: 'Title', artists: ['Kevin']),
      ),
      isNull,
    );
    expect(
      TrackMetadataValidator.validateForSave(
        const TrackMetadataState(
          title: 'Title',
          artists: ['Kevin'],
          availabilityType: 'exclusive_regions',
        ),
      ),
      'Select at least one country for availability.',
    );
    expect(
      TrackMetadataMapper.toEntity(
        const TrackMetadataState(
          title: 'Title',
          artists: ['Kevin'],
          availabilityType: 'excluded_regions',
          availabilityRegionsText: 'Egypt, us, Egypt',
        ),
      ).availabilityRegions,
      ['EG', 'US'],
    );
  });

  test('library uploads state and filter apply visibility query and sort rules', () {
    final privateItem = sampleUploadItem.copyWith(
      id: 'track-2',
      title: 'After Hours',
      artistDisplay: 'Luna',
      visibility: UploadVisibility.private,
      createdAt: DateTime.utc(2026, 2, 1),
    );
    final filtered = applyLibraryUploadsFilter(
      source: [sampleUploadItem, privateItem],
      query: 'luna',
      sort: UploadSortOrder.trackName,
      visibility: UploadVisibilityFilter.private,
    );
    final state = const LibraryUploadsState().copyWith(
      isLoading: false,
      items: [sampleUploadItem, privateItem],
      filteredItems: filtered,
      busyTrackId: 'track-1',
      error: 'old',
      clearBusyTrackId: true,
      clearError: true,
      sortOrder: UploadSortOrder.firstAdded,
      visibilityFilter: UploadVisibilityFilter.private,
    );

    expect(filtered, [privateItem]);
    expect(state.isEmpty, isFalse);
    expect(state.totalCount, 2);
    expect(state.busyTrackId, isNull);
    expect(state.error, isNull);
    expect(state.sortOrder, UploadSortOrder.firstAdded);
    expect(state.visibilityFilter, UploadVisibilityFilter.private);
  });

  test('library uploads repository providers build repository and usecases', () {
    final mockDio = MockDio();
    final mockMockApi = MockMockLibraryUploadsApi();
    final container = ProviderContainer(
      overrides: [
        libraryUploadsDioProvider.overrideWithValue(mockDio),
        mockLibraryUploadsApiProvider.overrideWithValue(mockMockApi),
        libraryUploadsUseMockProvider.overrideWith((_) => false),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(libraryUploadsApiProvider), isA<LibraryUploadsApi>());
    expect(
      container.read(libraryUploadsRepositoryProvider),
      isA<LibraryUploadsRepositoryImpl>(),
    );
    expect(container.read(getMyUploadsUsecaseProvider), isA<GetMyUploadsUsecase>());
    expect(
      container.read(getArtistToolsQuotaUsecaseProvider),
      isA<GetArtistToolsQuotaUsecase>(),
    );
    expect(container.read(deleteUploadUsecaseProvider), isA<DeleteUploadUsecase>());
    expect(container.read(replaceFileUsecaseProvider), isA<ReplaceFileUsecase>());
    expect(container.read(searchMyUploadsUsecaseProvider), isA<SearchMyUploadsUsecase>());
    expect(container.read(updateUploadUsecaseProvider), isA<UpdateUploadUsecase>());
  });
}
