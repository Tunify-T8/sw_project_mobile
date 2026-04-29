part of 'upload_provider.dart';

extension UploadNotifierFlowActions on UploadNotifier {
  Future<UploadedTrack?> pickAudioCreateDraftAndStartUpload(
    String userId,
  ) async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final file = await picker.pickAudioFile();

      if (file == null) {
        return null;
      }

      final blockedUploadMinutes = _blockedUploadMinutesFor(file);
      if (blockedUploadMinutes != null) {
        state = state.copyWith(
          isPreparingUpload: false,
          isUploading: false,
          hasUploadedAudio: false,
          uploadProgress: 0.0,
          clearSelectedAudio: true,
          clearCurrentTrack: true,
          blockedUploadMinutes: blockedUploadMinutes,
          error: null,
        );
        return null;
      }

      state = state.copyWith(
        selectedAudio: file,
        isPreparingUpload: true,
        isUploading: false,
        hasUploadedAudio: false,
        uploadProgress: 0.0,
        clearBlockedUploadMinutes: true,
        error: null,
      );

      final repository = ref.read(uploadRepositoryProvider);
      final createdTrack = await repository.createTrack(userId);

      state = state.copyWith(
        currentTrack: createdTrack,
        isPreparingUpload: false,
        isUploading: true,
        hasUploadedAudio: false,
      );

      final requestId = ++_activeUploadRequestId;
      _activeCancellationToken = UploadCancellationToken();
      _activeRestorePoint = null;

      unawaited(
        _uploadAudioInBackground(
          requestId: requestId,
          trackId: createdTrack.trackId,
          file: file,
          cancellationToken: _activeCancellationToken!,
          restorePoint: null,
        ),
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

  Future<PickedUploadFile?> replaceCurrentAudioAndStartUpload() async {
    final currentTrack = state.currentTrack;

    if (currentTrack == null) {
      state = state.copyWith(
        error: 'Create the track draft first, then replace the audio file.',
      );
      return null;
    }

    try {
      final picker = ref.read(filePickerServiceProvider);
      final file = await picker.pickAudioFile();

      if (file == null) {
        return null;
      }

      final restorePoint = _captureRestorePoint();

      state = state.copyWith(
        selectedAudio: file,
        isPreparingUpload: false,
        isUploading: true,
        hasUploadedAudio: false,
        uploadProgress: 0.0,
        clearBlockedUploadMinutes: true,
        error: null,
      );

      final requestId = ++_activeUploadRequestId;
      _activeCancellationToken = UploadCancellationToken();
      _activeRestorePoint = restorePoint;

      unawaited(
        _uploadAudioInBackground(
          requestId: requestId,
          trackId: currentTrack.trackId,
          file: file,
          cancellationToken: _activeCancellationToken!,
          restorePoint: restorePoint,
        ),
      );
      return file;
    } catch (error, stackTrace) {
      logUploadError('replace upload audio', error, stackTrace);
      state = state.copyWith(
        isUploading: false,
        error: userFriendlyUploadError(
          error,
          fallback: 'We could not replace that audio file. Please try again.',
        ),
      );
      return null;
    }
  }

  Future<bool> cancelCurrentUpload() async {
    if (!state.isPreparingUpload && !state.isUploading) {
      return state.uploadFinished;
    }

    final restorePoint = _activeRestorePoint;

    _activeUploadRequestId++;
    _activeCancellationToken?.cancel();
    _activeCancellationToken = null;
    _activeRestorePoint = null;

    if (restorePoint == null) {
      state = state.copyWith(
        isPreparingUpload: false,
        isUploading: false,
        hasUploadedAudio: false,
        uploadProgress: 0.0,
        clearBlockedUploadMinutes: true,
        error: null,
      );
      return false;
    }

    _restoreUploadState(restorePoint);
    return true;
  }

  void completeSavedUploadInBackground(String trackId) {
    final requestId = ++_activeCompletionRequestId;
    state = state.copyWith(
      isCompletingUpload: true,
      clearBlockedUploadMinutes: true,
      error: null,
    );
    unawaited(_completeSavedUploadInBackground(requestId, trackId));
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void discardDraft() {
    _activeUploadRequestId++;
    _activeCompletionRequestId++;
    _activeCancellationToken?.cancel();
    _activeCancellationToken = null;
    _activeRestorePoint = null;

    state = UploadState(
      quota: state.quota,
      isLoadingQuota: state.isLoadingQuota,
    );
  }
}
