part of 'upload_provider.dart';

extension UploadNotifierQuotaActions on UploadNotifier {
  Future<void> loadQuota(String userId) async {
    state = state.copyWith(
      isLoadingQuota: true,
      clearBlockedUploadMinutes: true,
      error: null,
    );

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

  void clearQuotaLimitPrompt() {
    state = state.copyWith(clearBlockedUploadMinutes: true, error: null);
  }

  void primeTrackForEditing({required String trackId}) {
    state = state.copyWith(
      currentTrack: UploadedTrack(
        trackId: trackId,
        status: UploadStatus.finished,
      ),
      hasUploadedAudio: true,
      uploadProgress: 1.0,
      clearBlockedUploadMinutes: true,
      error: null,
    );
  }
}
