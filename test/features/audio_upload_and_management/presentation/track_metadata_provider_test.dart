import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_genre.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_metadata_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockUploadRepository mockRepository;
  late MockFilePickerService mockFilePickerService;

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        uploadRepositoryProvider.overrideWithValue(mockRepository),
        filePickerServiceProvider.overrideWithValue(mockFilePickerService),
        currentArtistNameProvider.overrideWith((_) => 'Kevin'),
      ],
    );
  }

  setUp(() {
    mockRepository = MockUploadRepository();
    mockFilePickerService = MockFilePickerService();
  });

  test('prepareForNewUpload seeds title and primary artist', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    container.read(trackMetadataProvider.notifier).prepareForNewUpload('track.mp3');
    final state = container.read(trackMetadataProvider);

    expect(state.title, 'track.mp3');
    expect(state.artists, ['Kevin']);
  });

  test('prepareForEdit maps upload item values into editable metadata state', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    container.read(trackMetadataProvider.notifier).prepareForEdit(sampleUploadItem);
    final state = container.read(trackMetadataProvider);

    expect(state.title, 'Midnight Echo');
    expect(state.privacy, 'public');
    expect(state.tagsText, 'night, beats');
    expect(state.artists, ['Kevin']);
  });

  test('field helpers update metadata and validate artists', () async {
    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(trackMetadataProvider.notifier);

    notifier.prepareForNewUpload('track.mp3');
    notifier.setTitle('  New Title  ');
    notifier.setGenre(
      const UploadGenre(
        label: 'Rock',
        subGenre: 'rock',
        group: UploadGenreGroup.music,
      ),
    );
    notifier.setTagsText('one, two');
    notifier.setDescription('Description');
    notifier.setPrivacy('private');
    notifier.addArtist('Luna');
    notifier.removeArtist('Kevin');
    notifier.setRecordLabel('Label');
    notifier.setPublisher('Publisher');
    notifier.setIsrc('ISRC');
    notifier.setPLine('PLine');
    notifier.setHasScheduledRelease(true);
    notifier.setScheduledReleaseDate(DateTime.utc(2026, 4, 2));
    notifier.setContentWarning(true);
    notifier.setAllowDownloads(true);
    notifier.setOfflineListening(false);
    notifier.setIncludeInRss(false);
    notifier.setDisplayEmbedCode(false);
    notifier.setAppPlaybackEnabled(false);
    notifier.setAvailabilityType('exclusive_regions');
    notifier.setAvailabilityRegionsText('us, ca');
    notifier.setLicensing('creative_commons');

    final state = container.read(trackMetadataProvider);
    expect(state.title, '  New Title  ');
    expect(state.genreSubGenre, 'rock');
    expect(state.artists, ['Luna']);
    expect(state.allowDownloads, isTrue);
    expect(state.availabilityRegionsText, 'us, ca');

    notifier.addArtist(' ');
    expect(
      container.read(trackMetadataProvider).error,
      'Enter an artist name before adding it.',
    );

    notifier.addArtist('Luna');
    expect(
      container.read(trackMetadataProvider).error,
      'Luna is already in the artist list.',
    );

    notifier.removeArtist('Luna');
    expect(
      container.read(trackMetadataProvider).error,
      'At least one artist is required.',
    );
  });

  test('pickArtwork stores the selected path and reports failures', () async {
    when(
      mockFilePickerService.pickArtworkImage(fromCamera: false),
    ).thenAnswer((_) async => '/tmp/cover.png');

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(trackMetadataProvider.notifier);

    await notifier.pickArtwork();
    expect(container.read(trackMetadataProvider).artworkPath, '/tmp/cover.png');

    when(
      mockFilePickerService.pickArtworkImage(fromCamera: true),
    ).thenThrow(const UploadFlowException('Artwork failed.'));

    await notifier.pickArtwork(fromCamera: true);
    expect(container.read(trackMetadataProvider).error, 'Artwork failed.');
  });

  test('saveForNewUpload validates state before hitting the repository', () async {
    final container = buildContainer();
    addTearDown(container.dispose);

    final result = await container
        .read(trackMetadataProvider.notifier)
        .saveForNewUpload('track-1');

    expect(result, isFalse);
    expect(container.read(trackMetadataProvider).error, 'Title is required.');
    verifyNever(mockRepository.finalizeMetadata(trackId: anyNamed('trackId'), metadata: anyNamed('metadata')));
  });

  test('saveForNewUpload finalizes metadata and starts background completion', () async {
    final completion = Completer<UploadedTrack>();
    when(
      mockRepository.finalizeMetadata(
        trackId: 'track-1',
        metadata: anyNamed('metadata'),
      ),
    ).thenAnswer((_) async => sampleUploadedTrack);
    when(
      mockRepository.waitUntilProcessed('track-1'),
    ).thenAnswer((_) => completion.future);

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(trackMetadataProvider.notifier);
    notifier.prepareForNewUpload('track.mp3');
    notifier.setDescription('Description');

    final success = await notifier.saveForNewUpload('track-1');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(success, isTrue);
    expect(container.read(trackMetadataProvider).processingStatus, UploadStatus.processing);
    expect(container.read(uploadProvider).isCompletingUpload, isTrue);

    completion.complete(sampleUploadedTrack.copyWith(status: UploadStatus.finished));
  });

  test('saveForEdit updates metadata and stores failures', () async {
    when(
      mockRepository.updateTrackMetadata(
        trackId: 'track-1',
        metadata: anyNamed('metadata'),
      ),
    ).thenAnswer((_) async => sampleUploadedTrack.copyWith(status: UploadStatus.finished));

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(trackMetadataProvider.notifier);
    notifier.prepareForEdit(sampleUploadItem);

    final success = await notifier.saveForEdit('track-1');

    expect(success, isTrue);
    expect(container.read(trackMetadataProvider).processingStatus, UploadStatus.finished);

    when(
      mockRepository.updateTrackMetadata(
        trackId: 'track-2',
        metadata: anyNamed('metadata'),
      ),
    ).thenThrow(const UploadFlowException('Edit failed.'));

    notifier.prepareForEdit(sampleUploadItem.copyWith(id: 'track-2'));
    final failed = await notifier.saveForEdit('track-2');

    expect(failed, isFalse);
    expect(container.read(trackMetadataProvider).error, 'Edit failed.');
  });
}
