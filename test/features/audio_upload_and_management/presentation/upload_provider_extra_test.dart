import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/library_uploads_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../helpers/local_upload_test_mocks.dart';
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

  test('replaceCurrentAudioAndStartUpload reports a missing draft and clearError removes messages', () async {
    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(uploadProvider.notifier);

    await notifier.replaceCurrentAudioAndStartUpload();
    expect(
      container.read(uploadProvider).error,
      'Create the track draft first, then replace the audio file.',
    );

    notifier.clearError();
    expect(container.read(uploadProvider).error, isNull);
  });

  test('cancelCurrentUpload returns current uploadFinished state when nothing is active', () async {
    final container = buildContainer();
    addTearDown(container.dispose);
    final notifier = container.read(uploadProvider.notifier);

    expect(await notifier.cancelCurrentUpload(), isFalse);

    notifier.primeTrackForEditing(trackId: 'track-1');
    expect(await notifier.cancelCurrentUpload(), isTrue);
  });

  test('pickAudioCreateDraftAndStartUpload stores a friendly start error when draft creation fails', () async {
    when(
      mockFilePickerService.pickAudioFile(),
    ).thenAnswer((_) async => samplePickedUploadFile);
    when(
      mockRepository.createTrack('user-1'),
    ).thenThrow(const UploadFlowException('Create failed.'));

    final container = buildContainer();
    addTearDown(container.dispose);

    final result = await container
        .read(uploadProvider.notifier)
        .pickAudioCreateDraftAndStartUpload('user-1');

    expect(result, isNull);
    expect(container.read(uploadProvider).error, 'Create failed.');
  });

  test('completeSavedUploadInBackground stores a friendly processing error', () async {
    when(
      mockRepository.waitUntilProcessed('track-1'),
    ).thenThrow(const UploadFlowException('Processing failed.'));

    final container = buildContainer();
    addTearDown(container.dispose);

    container.read(uploadProvider.notifier).completeSavedUploadInBackground(
      'track-1',
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(uploadProvider);
    expect(state.isCompletingUpload, isFalse);
    expect(state.error, 'Processing failed.');
  });
}
