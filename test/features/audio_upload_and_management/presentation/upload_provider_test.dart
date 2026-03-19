import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockUploadRepository mockRepository;
  late MockFilePickerService mockFilePickerService;
  late MockGetMyUploadsUsecase mockGetMyUploads;
  late MockGetArtistToolsQuotaUsecase mockGetArtistToolsQuota;

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        uploadRepositoryProvider.overrideWithValue(mockRepository),
        filePickerServiceProvider.overrideWithValue(mockFilePickerService),
        getMyUploadsUsecaseProvider.overrideWithValue(mockGetMyUploads),
        getArtistToolsQuotaUsecaseProvider.overrideWithValue(
          mockGetArtistToolsQuota,
        ),
      ],
    );
  }

  setUp(() {
    mockRepository = MockUploadRepository();
    mockFilePickerService = MockFilePickerService();
    mockGetMyUploads = MockGetMyUploadsUsecase();
    mockGetArtistToolsQuota = MockGetArtistToolsQuotaUsecase();
    when(mockGetMyUploads.call()).thenAnswer((_) async => [sampleUploadItem]);
    when(
      mockGetArtistToolsQuota.call(),
    ).thenAnswer((_) async => sampleArtistToolsQuota);
  });

  test('loadQuota stores the returned quota', () async {
    when(
      mockRepository.getUploadQuota('user-1'),
    ).thenAnswer((_) async => sampleUploadQuota);

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
    when(
      mockRepository.getUploadQuota('user-1'),
    ).thenThrow(const UploadFlowException('Quota failed.'));

    final container = buildContainer();
    addTearDown(container.dispose);

    await container.read(uploadProvider.notifier).loadQuota('user-1');

    expect(container.read(uploadProvider).error, 'Quota failed.');
  });

  test('pickAudioCreateDraftAndStartUpload returns null when picker is cancelled', () async {
    when(mockFilePickerService.pickAudioFile()).thenAnswer((_) async => null);

    final container = buildContainer();
    addTearDown(container.dispose);

    final result = await container
        .read(uploadProvider.notifier)
        .pickAudioCreateDraftAndStartUpload('user-1');

    expect(result, isNull);
    expect(container.read(uploadProvider).selectedAudio, isNull);
  });

  test('pickAudioCreateDraftAndStartUpload uploads the picked audio', () async {
    const createdTrack = UploadedTrack(
      trackId: 'track-1',
      status: UploadStatus.idle,
    );
    when(
      mockFilePickerService.pickAudioFile(),
    ).thenAnswer((_) async => samplePickedUploadFile);
    when(
      mockRepository.createTrack('user-1'),
    ).thenAnswer((_) async => createdTrack);
    when(
      mockRepository.uploadAudio(
        trackId: 'track-1',
        file: samplePickedUploadFile,
        onProgress: anyNamed('onProgress'),
        cancellationToken: anyNamed('cancellationToken'),
      ),
    ).thenAnswer((invocation) async {
      final onProgress =
          invocation.namedArguments[#onProgress] as void Function(double);
      onProgress(0.4);
      onProgress(1.0);
      return sampleUploadedTrack;
    });

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
    when(
      mockFilePickerService.pickAudioFile(),
    ).thenAnswer((_) async => samplePickedUploadFile);
    when(
      mockRepository.uploadAudio(
        trackId: 'track-1',
        file: samplePickedUploadFile,
        onProgress: anyNamed('onProgress'),
        cancellationToken: anyNamed('cancellationToken'),
      ),
    ).thenAnswer((invocation) async {
      final onProgress =
          invocation.namedArguments[#onProgress] as void Function(double);
      onProgress(0.995);
      throw DioException(
        requestOptions: RequestOptions(path: '/cloudinary/upload'),
        type: DioExceptionType.receiveTimeout,
      );
    });

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
    when(
      mockFilePickerService.pickAudioFile(),
    ).thenAnswer((_) async => samplePickedUploadFile);
    when(
      mockRepository.uploadAudio(
        trackId: 'track-1',
        file: samplePickedUploadFile,
        onProgress: anyNamed('onProgress'),
        cancellationToken: anyNamed('cancellationToken'),
      ),
    ).thenAnswer((invocation) async {
      final onProgress =
          invocation.namedArguments[#onProgress] as void Function(double);
      final cancellationToken =
          invocation.namedArguments[#cancellationToken]
              as dynamic;
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
    });

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
    when(
      mockRepository.waitUntilProcessed('track-1'),
    ).thenAnswer(
      (_) async => sampleUploadedTrack.copyWith(status: UploadStatus.finished),
    );

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
    verify(mockGetMyUploads.call()).called(1);
    verify(mockGetArtistToolsQuota.call()).called(1);
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
