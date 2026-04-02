part of 'upload_provider.dart';

extension _UploadNotifierBackground on UploadNotifier {
  Future<void> _uploadAudioInBackground({
    required int requestId,
    required String trackId,
    required PickedUploadFile file,
    required UploadCancellationToken cancellationToken,
    required _UploadRestorePoint? restorePoint,
  }) async {
    try {
      final repository = ref.read(uploadRepositoryProvider);

      final uploadedTrack = await repository.uploadAudio(
        trackId: trackId,
        file: file,
        cancellationToken: cancellationToken,
        onProgress: (progress) {
          if (!_isActiveRequest(requestId)) return;
          state = state.copyWith(uploadProgress: progress.clamp(0.0, 1.0));
        },
      );

      if (!_isActiveRequest(requestId)) return;

      final nextQuota = restorePoint == null
          ? _consumeQuotaForNewUpload(state.quota, file)
          : state.quota;

      state = state.copyWith(
        isPreparingUpload: false,
        isUploading: false,
        hasUploadedAudio: true,
        uploadProgress: 1.0,
        currentTrack: uploadedTrack,
        quota: nextQuota,
        clearBlockedUploadMinutes: true,
        error: null,
      );
    } catch (error, stackTrace) {
      if (!_isActiveRequest(requestId)) return;

      if (_isCancellationError(error)) {
        if (restorePoint != null) {
          _restoreUploadState(restorePoint);
        }
        return;
      }

      logUploadError('upload audio in background', error, stackTrace);

      final message = userFriendlyUploadError(
        error,
        fallback: 'We could not upload that audio file. Please try again.',
      );

      if (restorePoint != null) {
        _restoreUploadState(restorePoint, errorMessage: message);
        return;
      }

      state = state.copyWith(
        isPreparingUpload: false,
        isUploading: false,
        hasUploadedAudio: false,
        uploadProgress: 0.0,
        error: message,
      );
    } finally {
      if (_isActiveRequest(requestId)) {
        _activeCancellationToken = null;
        _activeRestorePoint = null;
      }
    }
  }

  Future<void> _completeSavedUploadInBackground(
    int requestId,
    String trackId,
  ) async {
    try {
      final repository = ref.read(uploadRepositoryProvider);
      final finalTrack = await repository.waitUntilProcessed(trackId);

      if (!_isActiveCompletionRequest(requestId)) {
        return;
      }

      state = state.copyWith(
        isCompletingUpload: false,
        currentTrack: finalTrack,
        clearBlockedUploadMinutes: true,
        error: null,
      );

      try {
        await ref.read(libraryUploadsProvider.notifier).refresh();
      } catch (_) {}

      try {
        final userId = ref.read(currentUploadUserIdProvider);
        await loadQuota(userId);
      } catch (_) {}

      if (!_isActiveCompletionRequest(requestId)) {
        return;
      }

      state = UploadState(
        quota: state.quota,
        isLoadingQuota: state.isLoadingQuota,
      );
    } catch (error, stackTrace) {
      if (!_isActiveCompletionRequest(requestId)) {
        return;
      }

      logUploadError('complete saved upload in background', error, stackTrace);
      state = state.copyWith(
        isCompletingUpload: false,
        error: userFriendlyUploadError(
          error,
          fallback:
              'We could not finish processing that upload. Please try again.',
        ),
      );
    }
  }
}
