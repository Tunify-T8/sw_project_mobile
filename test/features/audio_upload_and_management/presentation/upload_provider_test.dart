import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/file_picker_service.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/picked_upload_file.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/upload_repository.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_dependencies_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_provider.dart';
import 'package:software_project/features/audio_upload_and_management/presentation/providers/upload_repository_provider.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

void main() {
  const pickedFile = PickedUploadFile(
    name: 'replacement.mp3',
    path: '/tmp/replacement.mp3',
    sizeBytes: 1024,
  );

  test('restores the previous upload when replace times out', () async {
    final container = ProviderContainer(
      overrides: [
        filePickerServiceProvider.overrideWithValue(
          _FakeFilePickerService(result: pickedFile),
        ),
        uploadRepositoryProvider.overrideWithValue(
          _FakeUploadRepository(
            uploadAudioHandler:
                ({
                  required trackId,
                  required file,
                  required onProgress,
                  required cancellationToken,
                }) async {
                  onProgress(0.995);
                  throw DioException(
                    requestOptions: RequestOptions(path: '/cloudinary/upload'),
                    type: DioExceptionType.receiveTimeout,
                  );
                },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(uploadProvider.notifier);
    notifier.primeTrackForEditing(trackId: 'track-1');

    await notifier.replaceCurrentAudioAndStartUpload();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(uploadProvider);
    expect(state.isUploading, isFalse);
    expect(state.uploadFinished, isTrue);
    expect(state.currentTrack?.trackId, equals('track-1'));
    expect(state.error, equals('The request timed out. Please try again.'));
  });

  test(
    'cancelling a replace restores the previous upload without an error',
    () async {
      final cancellationSeen = Completer<void>();

      final container = ProviderContainer(
        overrides: [
          filePickerServiceProvider.overrideWithValue(
            _FakeFilePickerService(result: pickedFile),
          ),
          uploadRepositoryProvider.overrideWithValue(
            _FakeUploadRepository(
              uploadAudioHandler:
                  ({
                    required trackId,
                    required file,
                    required onProgress,
                    required cancellationToken,
                  }) async {
                    onProgress(0.45);
                    final completer = Completer<UploadedTrack>();

                    cancellationToken?.addListener(() {
                      if (!cancellationSeen.isCompleted) {
                        cancellationSeen.complete();
                      }
                      if (!completer.isCompleted) {
                        completer.completeError(
                          const UploadCancelledException(),
                        );
                      }
                    });

                    return completer.future;
                  },
            ),
          ),
        ],
      );
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
      expect(state.currentTrack?.trackId, equals('track-1'));
    },
  );
}

typedef _UploadAudioHandler =
    Future<UploadedTrack> Function({
      required String trackId,
      required PickedUploadFile file,
      required void Function(double progress) onProgress,
      required UploadCancellationToken? cancellationToken,
    });

class _FakeUploadRepository implements UploadRepository {
  _FakeUploadRepository({required this.uploadAudioHandler});

  final _UploadAudioHandler uploadAudioHandler;

  @override
  Future<UploadQuota> getUploadQuota(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<UploadedTrack> createTrack(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  }) {
    return uploadAudioHandler(
      trackId: trackId,
      file: file,
      onProgress: onProgress,
      cancellationToken: cancellationToken,
    );
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    throw UnimplementedError();
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) async {
    throw UnimplementedError();
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTrack(String trackId) async {}
}

class _FakeFilePickerService extends FilePickerService {
  _FakeFilePickerService({required this.result});

  final PickedUploadFile? result;

  @override
  Future<PickedUploadFile?> pickAudioFile() async => result;
}
