import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/file_picker_service.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/picked_upload_file.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_genre.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/upload_repository.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/track_metadata_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../helpers/upload_test_data.dart';

class FakeUploadRepository implements UploadRepository {
  int finalizeMetadataCalls = 0;
  int updateTrackMetadataCalls = 0;

  Future<UploadedTrack> Function({
    required String trackId,
    required TrackMetadata metadata,
  })? finalizeMetadataHandler;

  Future<UploadedTrack> Function({
    required String trackId,
    required TrackMetadata metadata,
  })? updateTrackMetadataHandler;

  Future<UploadedTrack> Function(String trackId)? getTrackStatusHandler;

  @override
  Future<UploadQuota> getUploadQuota(String userId) async => sampleUploadQuota;

  @override
  Future<UploadedTrack> createTrack(String userId) async => sampleUploadedTrack;

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  }) async {
    onProgress(1.0);
    return sampleUploadedTrack;
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    finalizeMetadataCalls++;
    final handler = finalizeMetadataHandler;
    if (handler != null) {
      return handler(trackId: trackId, metadata: metadata);
    }
    return sampleUploadedTrack;
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
  }

  @override
  Future<UploadedTrack> getTrackStatus(String trackId) async {
    final handler = getTrackStatusHandler;
    if (handler != null) {
      return handler(trackId);
    }
    return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) async {
    return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    updateTrackMetadataCalls++;
    final handler = updateTrackMetadataHandler;
    if (handler != null) {
      return handler(trackId: trackId, metadata: metadata);
    }
    return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
  }

  @override
  Future<void> deleteTrack(String trackId) async {}
}

class FakeFilePickerService extends FilePickerService {
  Future<String?> Function({bool fromCamera})? artworkHandler;

  @override
  Future<String?> pickArtworkImage({bool fromCamera = false}) async {
    final handler = artworkHandler;
    if (handler != null) {
      return handler(fromCamera: fromCamera);
    }
    return null;
  }

  @override
  Future<PickedUploadFile?> pickAudioFile() async => null;
}

void main() {
  late FakeUploadRepository fakeRepository;
  late FakeFilePickerService fakeFilePickerService;

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        uploadRepositoryProvider.overrideWithValue(fakeRepository),
        filePickerServiceProvider.overrideWithValue(fakeFilePickerService),
        currentArtistNameProvider.overrideWith((_) => 'Kevin'),
      ],
    );
  }

  setUp(() {
    fakeRepository = FakeUploadRepository();
    fakeFilePickerService = FakeFilePickerService();
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
    fakeFilePickerService.artworkHandler = ({bool fromCamera = false}) async {
      return '/tmp/cover.png';
    };

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(trackMetadataProvider.notifier);

    await notifier.pickArtwork();
    expect(container.read(trackMetadataProvider).artworkPath, '/tmp/cover.png');

    fakeFilePickerService.artworkHandler = ({bool fromCamera = false}) async {
      throw const UploadFlowException('Artwork failed.');
    };

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
    expect(fakeRepository.finalizeMetadataCalls, 0);
  });

  test('saveForNewUpload finalizes metadata and starts background completion', () async {
    fakeRepository.finalizeMetadataHandler = ({
      required String trackId,
      required TrackMetadata metadata,
    }) async {
      expect(trackId, 'track-1');
      expect(metadata.title, 'track.mp3');
      return sampleUploadedTrack;
    };

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(trackMetadataProvider.notifier);
    notifier.prepareForNewUpload('track.mp3');
    notifier.setDescription('Description');

    final success = await notifier.saveForNewUpload('track-1');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(success, isTrue);
    expect(fakeRepository.finalizeMetadataCalls, 1);
    expect(
      container.read(trackMetadataProvider).processingStatus,
      UploadStatus.processing,
    );
    expect(container.read(trackMetadataProvider).isPolling, isTrue);
  });

  test('saveForEdit updates metadata and stores failures', () async {
    fakeRepository.updateTrackMetadataHandler = ({
      required String trackId,
      required TrackMetadata metadata,
    }) async {
      expect(trackId, 'track-1');
      expect(metadata.title, 'Midnight Echo');
      return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
    };

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(trackMetadataProvider.notifier);
    notifier.prepareForEdit(sampleUploadItem);

    final success = await notifier.saveForEdit('track-1');

    expect(success, isTrue);
    expect(fakeRepository.updateTrackMetadataCalls, 1);
    expect(
      container.read(trackMetadataProvider).processingStatus,
      UploadStatus.finished,
    );

    fakeRepository.updateTrackMetadataHandler = ({
      required String trackId,
      required TrackMetadata metadata,
    }) async {
      throw const UploadFlowException('Edit failed.');
    };

    notifier.prepareForEdit(sampleUploadItem.copyWith(id: 'track-2'));
    final failed = await notifier.saveForEdit('track-2');

    expect(failed, isFalse);
    expect(container.read(trackMetadataProvider).error, 'Edit failed.');
  });
}