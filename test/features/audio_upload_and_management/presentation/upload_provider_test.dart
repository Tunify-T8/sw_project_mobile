import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/file_picker_service.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/artist_tools_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/picked_upload_file.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/library_uploads_repository.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/upload_repository.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_artist_tools_quota_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_my_uploads_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../helpers/upload_test_data.dart';

class FakeUploadRepository implements UploadRepository {
  Future<UploadQuota> Function(String userId)? getUploadQuotaHandler;
  Future<UploadedTrack> Function(String userId)? createTrackHandler;
  Future<UploadedTrack> Function({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  })? uploadAudioHandler;
  Future<UploadedTrack> Function(String trackId)? waitUntilProcessedHandler;

  @override
  Future<UploadQuota> getUploadQuota(String userId) async {
    final handler = getUploadQuotaHandler;
    if (handler != null) return handler(userId);
    return sampleUploadQuota;
  }

  @override
  Future<UploadedTrack> createTrack(String userId) async {
    final handler = createTrackHandler;
    if (handler != null) return handler(userId);
    return const UploadedTrack(trackId: 'track-1', status: UploadStatus.idle);
  }

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  }) async {
    final handler = uploadAudioHandler;
    if (handler != null) {
      return handler(
        trackId: trackId,
        file: file,
        onProgress: onProgress,
        cancellationToken: cancellationToken,
      );
    }
    onProgress(1.0);
    return sampleUploadedTrack;
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    return sampleUploadedTrack;
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    final handler = waitUntilProcessedHandler;
    if (handler != null) return handler(trackId);
    return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
  }

  @override
  Future<UploadedTrack> getTrackStatus(String trackId) async {
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
    return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
  }

  @override
  Future<void> deleteTrack(String trackId) async {}
}

class FakeFilePickerService extends FilePickerService {
  Future<PickedUploadFile?> Function()? pickAudioHandler;

  @override
  Future<PickedUploadFile?> pickAudioFile() async {
    final handler = pickAudioHandler;
    if (handler != null) return handler();
    return null;
  }

  @override
  Future<String?> pickArtworkImage({bool fromCamera = false}) async => null;
}

class FakeLibraryUploadsRepository implements LibraryUploadsRepository {
  List<UploadItem> uploads = [sampleUploadItem];
  ArtistToolsQuota quota = sampleArtistToolsQuota;
  int getMyUploadsCalls = 0;
  int getArtistToolsQuotaCalls = 0;

  @override
  Future<List<UploadItem>> getMyUploads() async {
    getMyUploadsCalls++;
    return uploads;
  }

  @override
  Future<ArtistToolsQuota> getArtistToolsQuota() async {
    getArtistToolsQuotaCalls++;
    return quota;
  }

  @override
  Future<void> deleteUpload(String trackId) async {}

  @override
  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) async {}

  @override
  Future<UploadItem> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) async {
    return sampleUploadItem;
  }
}

void main() {
  late FakeUploadRepository fakeUploadRepository;
  late FakeFilePickerService fakeFilePickerService;
  late FakeLibraryUploadsRepository fakeLibraryRepository;

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        uploadRepositoryProvider.overrideWithValue(fakeUploadRepository),
        filePickerServiceProvider.overrideWithValue(fakeFilePickerService),
        currentUploadUserIdProvider.overrideWith((_) => 'user-1'),
        getMyUploadsUsecaseProvider.overrideWithValue(
          GetMyUploadsUsecase(fakeLibraryRepository),
        ),
        getArtistToolsQuotaUsecaseProvider.overrideWithValue(
          GetArtistToolsQuotaUsecase(fakeLibraryRepository),
        ),
      ],
    );
  }

  setUp(() {
    fakeUploadRepository = FakeUploadRepository();
    fakeFilePickerService = FakeFilePickerService();
    fakeLibraryRepository = FakeLibraryUploadsRepository();
  });

  test('loadQuota stores the returned quota', () async {
    fakeUploadRepository.getUploadQuotaHandler = (userId) async {
      expect(userId, 'user-1');
      return sampleUploadQuota;
    };

    final container = buildContainer();
    addTearDown(container.dispose);

    await container.read(uploadProvider.notifier).loadQuota('user-1');

    final state = container.read(uploadProvider);
    expect(state.quota?.tier, sampleUploadQuota.tier);
    expect(
      state.quota?.uploadMinutesRemaining,
      sampleUploadQuota.uploadMinutesRemaining,
    );
    expect(state.isLoadingQuota, isFalse);
  });

  test('loadQuota stores a friendly error on failure', () async {
    fakeUploadRepository.getUploadQuotaHandler = (userId) async {
      throw const UploadFlowException('Quota failed.');
    };

    final container = buildContainer();
    addTearDown(container.dispose);

    await container.read(uploadProvider.notifier).loadQuota('user-1');

    expect(container.read(uploadProvider).error, 'Quota failed.');
  });

  test('pickAudioCreateDraftAndStartUpload returns null when picker is cancelled', () async {
    fakeFilePickerService.pickAudioHandler = () async => null;

    final container = buildContainer();
    addTearDown(container.dispose);

    final result = await container
        .read(uploadProvider.notifier)
        .pickAudioCreateDraftAndStartUpload('user-1');

    expect(result, isNull);
    expect(container.read(uploadProvider).selectedAudio, isNull);
  });

  test('pickAudioCreateDraftAndStartUpload uploads the picked audio', () async {
    fakeFilePickerService.pickAudioHandler = () async => samplePickedUploadFile;

    fakeUploadRepository.createTrackHandler = (userId) async {
      return const UploadedTrack(
        trackId: 'track-1',
        status: UploadStatus.idle,
      );
    };

    fakeUploadRepository.uploadAudioHandler = ({
      required String trackId,
      required PickedUploadFile file,
      required void Function(double progress) onProgress,
      UploadCancellationToken? cancellationToken,
    }) async {
      onProgress(0.4);
      onProgress(1.0);
      return sampleUploadedTrack;
    };

    final container = buildContainer();
    addTearDown(container.dispose);

    final result = await container
        .read(uploadProvider.notifier)
        .pickAudioCreateDraftAndStartUpload('user-1');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(result?.trackId, 'track-1');
    final state = container.read(uploadProvider);
    expect(state.uploadFinished, isTrue);
    expect(state.currentTrack?.trackId, 'track-1');
    expect(state.uploadProgress, 1.0);
  });

  test('restores the previous upload when replace times out', () async {
    fakeFilePickerService.pickAudioHandler = () async => samplePickedUploadFile;

    fakeUploadRepository.uploadAudioHandler = ({
      required String trackId,
      required PickedUploadFile file,
      required void Function(double progress) onProgress,
      UploadCancellationToken? cancellationToken,
    }) async {
      onProgress(0.995);
      throw DioException(
        requestOptions: RequestOptions(path: '/tracks/upload'),
        type: DioExceptionType.receiveTimeout,
      );
    };

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(uploadProvider.notifier);
    notifier.primeTrackForEditing(trackId: 'track-1');

    await notifier.replaceCurrentAudioAndStartUpload();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(uploadProvider);
    expect(state.isUploading, isFalse);
    expect(state.uploadFinished, isTrue);
    expect(state.currentTrack?.trackId, 'track-1');
    expect(state.error, 'The request timed out. Please try again.');
  });

  test('cancelling a replace restores the previous upload without an error', () async {
    final cancellationSeen = Completer<void>();

    fakeFilePickerService.pickAudioHandler = () async => samplePickedUploadFile;

    fakeUploadRepository.uploadAudioHandler = ({
      required String trackId,
      required PickedUploadFile file,
      required void Function(double progress) onProgress,
      UploadCancellationToken? cancellationToken,
    }) async {
      onProgress(0.45);
      final completer = Completer<UploadedTrack>();

      cancellationToken?.addListener(() {
        if (!cancellationSeen.isCompleted) {
          cancellationSeen.complete();
        }
        if (!completer.isCompleted) {
          completer.completeError(const UploadCancelledException());
        }
      });

      return completer.future;
    };

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(uploadProvider.notifier);
    notifier.primeTrackForEditing(trackId: 'track-1');

    await notifier.replaceCurrentAudioAndStartUpload();
    final restored = await notifier.cancelCurrentUpload();
    await cancellationSeen.future;
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(uploadProvider);
    expect(restored, isTrue);
    expect(state.isUploading, isFalse);
    expect(state.error, isNull);
    expect(state.uploadFinished, isTrue);
    expect(state.currentTrack?.trackId, 'track-1');
  });

  test('completeSavedUploadInBackground refreshes uploads and resets local state', () async {
    fakeUploadRepository.waitUntilProcessedHandler = (trackId) async {
      return sampleUploadedTrack.copyWith(status: UploadStatus.finished);
    };

    fakeUploadRepository.getUploadQuotaHandler = (userId) async {
      return sampleUploadQuota;
    };

    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(uploadProvider.notifier);
    notifier.primeTrackForEditing(trackId: 'track-1');

    notifier.completeSavedUploadInBackground('track-1');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(uploadProvider);
    expect(state.isCompletingUpload, isFalse);
    expect(state.currentTrack, isNull);
    expect(state.selectedAudio, isNull);
    expect(fakeLibraryRepository.getMyUploadsCalls, 1);
    expect(fakeLibraryRepository.getArtistToolsQuotaCalls, 1);
  });

  test('discardDraft clears upload-specific state', () {
    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(uploadProvider.notifier);
    notifier.primeTrackForEditing(trackId: 'track-1');

    notifier.discardDraft();

    final state = container.read(uploadProvider);
    expect(state.currentTrack, isNull);
    expect(state.uploadProgress, 0);
    expect(state.error, isNull);
  });
}