part of 'upload_provider.dart';

extension _UploadNotifierHelpers on UploadNotifier {
  bool _isActiveRequest(int requestId) => _activeUploadRequestId == requestId;

  bool _isActiveCompletionRequest(int requestId) =>
      _activeCompletionRequestId == requestId;

  bool _isCancellationError(Object error) {
    return error is UploadCancelledException ||
        (error is DioException && error.type == DioExceptionType.cancel);
  }

  int? _blockedUploadMinutesFor(PickedUploadFile file) {
    final quota = state.quota;
    final durationSeconds = file.durationSeconds;

    if (durationSeconds == null || durationSeconds <= 0) {
      return null;
    }

    final subscription = ref
        .read(subscriptionNotifierProvider)
        .currentSubscription;
    final uploadLimit = subscription.features.uploadLimit;

    if (uploadLimit < 0) {
      return null;
    }

    final uploadMinutesUsed = quota?.uploadMinutesUsed ?? 0;
    final requiredMinutes = quota?.minutesRequiredForDuration(durationSeconds) ??
        ((durationSeconds + 59) ~/ 60);

    if (uploadMinutesUsed + requiredMinutes <= uploadLimit) {
      return null;
    }

    return requiredMinutes;
  }

  UploadQuota? _consumeQuotaForNewUpload(
    UploadQuota? quota,
    PickedUploadFile file,
  ) {
    final durationSeconds = file.durationSeconds;

    if (quota == null || durationSeconds == null || durationSeconds <= 0) {
      return quota;
    }

    return quota.consumeDuration(durationSeconds);
  }

  _UploadRestorePoint? _captureRestorePoint() {
    final currentTrack = state.currentTrack;
    if (!state.uploadFinished || currentTrack == null) {
      return null;
    }

    return _UploadRestorePoint(
      currentTrack: currentTrack,
      selectedAudio: state.selectedAudio,
      uploadProgress: 1.0,
      hasUploadedAudio: true,
    );
  }

  void _restoreUploadState(
    _UploadRestorePoint restorePoint, {
    String? errorMessage,
  }) {
    state = state.copyWith(
      isPreparingUpload: false,
      isUploading: false,
      hasUploadedAudio: restorePoint.hasUploadedAudio,
      selectedAudio: restorePoint.selectedAudio,
      clearSelectedAudio: restorePoint.selectedAudio == null,
      currentTrack: restorePoint.currentTrack,
      clearCurrentTrack: restorePoint.currentTrack == null,
      uploadProgress: restorePoint.uploadProgress,
      clearBlockedUploadMinutes: true,
      error: errorMessage,
    );
  }
}

class _UploadRestorePoint {
  const _UploadRestorePoint({
    required this.currentTrack,
    required this.selectedAudio,
    required this.uploadProgress,
    required this.hasUploadedAudio,
  });

  final UploadedTrack? currentTrack;
  final PickedUploadFile? selectedAudio;
  final double uploadProgress;
  final bool hasUploadedAudio;
}
