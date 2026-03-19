import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/upload_cancellation_token.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../shared/upload_error_helpers.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';
import 'upload_state.dart';

class UploadNotifier extends Notifier<UploadState> {
  int _activeUploadRequestId = 0;
  UploadCancellationToken? _activeCancellationToken;
  _UploadRestorePoint? _activeRestorePoint;

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
      hasUploadedAudio: true,
      uploadProgress: 1.0,
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
        hasUploadedAudio: false,
        uploadProgress: 0.0,
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

      final restorePoint = _captureRestorePoint();
      state = state.copyWith(
        selectedAudio: file,
        isPreparingUpload: false,
        isUploading: true,
        hasUploadedAudio: false,
        uploadProgress: 0.0,
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
        error: null,
      );
      return false;
    }

    _restoreUploadState(restorePoint);
    return true;
  }

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

      state = state.copyWith(
        isPreparingUpload: false,
        isUploading: false,
        hasUploadedAudio: true,
        uploadProgress: 1.0,
        currentTrack: uploadedTrack,
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

  void clearError() {
    state = state.copyWith(error: null);
  }

  void discardDraft() {
    _activeUploadRequestId++;
    _activeCancellationToken?.cancel();
    _activeCancellationToken = null;
    _activeRestorePoint = null;

    state = UploadState(
      quota: state.quota,
      isLoadingQuota: state.isLoadingQuota,
    );
  }

  bool _isActiveRequest(int requestId) => _activeUploadRequestId == requestId;

  bool _isCancellationError(Object error) {
    return error is UploadCancelledException ||
        (error is DioException && error.type == DioExceptionType.cancel);
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
      error: errorMessage,
    );
  }
}

final uploadProvider = NotifierProvider<UploadNotifier, UploadState>(
  UploadNotifier.new,
);

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
