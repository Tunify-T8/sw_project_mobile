import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../shared/upload_error_helpers.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';
import 'upload_state.dart';

class UploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() {
    return const UploadState();
  }

  Future<void> loadQuota(String userId) async {
    state = state.copyWith(isLoadingQuota: true, error: null);

    try {
      final repository = ref.read(uploadRepositoryProvider);
      final quota = await repository.getUploadQuota(userId);

      state = state.copyWith(isLoadingQuota: false, quota: quota);
    } catch (error, stackTrace) {
      logUploadError('load upload quota', error, stackTrace);
      state = state.copyWith(
        isLoadingQuota: false,
        error: userFriendlyUploadError(
          error,
          fallback: 'We could not load your upload tools right now.',
        ),
      );
    }
  }

  void primeTrackForEditing({required String trackId}) {
    state = state.copyWith(
      currentTrack: UploadedTrack(
        trackId: trackId,
        status: UploadStatus.finished,
      ),
      error: null,
    );
  }

  Future<UploadedTrack?> pickAudioCreateDraftAndStartUpload(
    String userId,
  ) async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final file = await picker.pickAudioFile();

      if (file == null) {
        return null;
      }

      state = state.copyWith(
        selectedAudio: file,
        isPreparingUpload: true,
        isUploading: false,
        uploadProgress: 0.0,
        error: null,
      );

      final repository = ref.read(uploadRepositoryProvider);
      final createdTrack = await repository.createTrack(userId);

      state = state.copyWith(
        currentTrack: createdTrack,
        isPreparingUpload: false,
        isUploading: true,
      );

      unawaited(
        _uploadAudioInBackground(trackId: createdTrack.trackId, file: file),
      );

      return createdTrack;
    } catch (error, stackTrace) {
      logUploadError('start upload flow', error, stackTrace);
      state = state.copyWith(
        isPreparingUpload: false,
        isUploading: false,
        error: userFriendlyUploadError(
          error,
          fallback:
              'We could not start the upload. Please pick your file again.',
        ),
      );
      return null;
    }
  }

  Future<void> replaceCurrentAudioAndStartUpload() async {
    final currentTrack = state.currentTrack;

    if (currentTrack == null) {
      state = state.copyWith(
        error: 'Create the track draft first, then replace the audio file.',
      );
      return;
    }

    try {
      final picker = ref.read(filePickerServiceProvider);
      final file = await picker.pickAudioFile();

      if (file == null) {
        return;
      }

      state = state.copyWith(
        selectedAudio: file,
        isPreparingUpload: false,
        isUploading: true,
        uploadProgress: 0.0,
        error: null,
      );

      unawaited(
        _uploadAudioInBackground(trackId: currentTrack.trackId, file: file),
      );
    } catch (error, stackTrace) {
      logUploadError('replace upload audio', error, stackTrace);
      state = state.copyWith(
        isUploading: false,
        error: userFriendlyUploadError(
          error,
          fallback: 'We could not replace that audio file. Please try again.',
        ),
      );
    }
  }

  Future<void> _uploadAudioInBackground({
    required String trackId,
    required PickedUploadFile file,
  }) async {
    try {
      final repository = ref.read(uploadRepositoryProvider);

      final uploadedTrack = await repository.uploadAudio(
        trackId: trackId,
        file: file,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      state = state.copyWith(
        isPreparingUpload: false,
        isUploading: false,
        uploadProgress: 1.0,
        currentTrack: uploadedTrack,
      );
    } catch (error, stackTrace) {
      logUploadError('upload audio in background', error, stackTrace);
      state = state.copyWith(
        isPreparingUpload: false,
        isUploading: false,
        error: userFriendlyUploadError(
          error,
          fallback: 'We could not upload that audio file. Please try again.',
        ),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void discardDraft() {
    state = UploadState(
      quota: state.quota,
      isLoadingQuota: state.isLoadingQuota,
    );
  }
}

final uploadProvider = NotifierProvider<UploadNotifier, UploadState>(
  UploadNotifier.new,
);
