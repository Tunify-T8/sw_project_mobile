import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_genre.dart';
import '../../domain/entities/upload_item.dart';
import '../../domain/entities/upload_status.dart';
import '../../shared/upload_error_helpers.dart';
import 'track_metadata_mapper.dart';
import 'track_metadata_state_factory.dart';
import 'track_metadata_state.dart';
import 'track_metadata_validator.dart';
import 'upload_dependencies_provider.dart';
import 'upload_provider.dart';
import 'upload_repository_provider.dart';

part 'track_metadata_notifier_fields.dart';

class TrackMetadataNotifier extends Notifier<TrackMetadataState>
    with TrackMetadataNotifierFields {
  @override
  TrackMetadataState build() => TrackMetadataState(artists: [_primaryArtist]);

  String get _primaryArtist => ref.read(currentArtistNameProvider);

  void prepareForNewUpload(String fileName) {
    state = buildNewUploadTrackMetadataState(
      fileName: fileName,
      primaryArtist: _primaryArtist,
    );
  }

  void prepareForEdit(UploadItem item) {
    state = buildEditTrackMetadataState(
      item: item,
      primaryArtist: _primaryArtist,
    );
  }

  Future<bool> saveForNewUpload(String trackId) async {
    if (!_beginSave()) return false;

    try {
      final repository = ref.read(uploadRepositoryProvider);
      final metadata = TrackMetadataMapper.toEntity(state);
      await repository.finalizeMetadata(
        trackId: trackId,
        metadata: metadata,
      );

      // Metadata saved — now poll status until finished/failed.
      // This drives the UploadProgressScreen directly via processingStatus.
      state = state.copyWith(
        isSaving: false,
        isPolling: true,
        processingStatus: UploadStatus.processing,
        error: null,
      );

      _pollUntilDone(trackId);
      return true;
    } catch (error, stackTrace) {
      _failSave(
        error,
        stackTrace,
        fallback:
            'We could not publish this track right now. Please try again.',
      );
      return false;
    }
  }

  /// Polls GET /tracks/:id/status every 5 seconds and updates
  /// processingStatus so UploadProgressScreen reacts in real time.
  Future<void> _pollUntilDone(String trackId) async {
    const maxAttempts = 60; // 5 min max (60 x 5s)
    final repository = ref.read(uploadRepositoryProvider);

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 5));

      // Guard: notifier may have been disposed
      try {
        // GET /tracks/:id/status — lightweight, purpose-built for polling.
        // Returns { id, transcodingStatus, durationSeconds, audioUrl, waveformUrl }.
        // Do NOT use getTrackDetails here — it returns audioUrl: "" while
        // processing and the status never transitions to finished from that.
        final track = await repository.getTrackStatus(trackId);
        state = state.copyWith(
          processingStatus: track.status,
          finalTrack: track,
          isPolling: track.status == UploadStatus.processing ||
              track.status == UploadStatus.uploading,
          error: null,
        );

        if (track.status == UploadStatus.finished ||
            track.status == UploadStatus.failed) {
          ref
              .read(uploadProvider.notifier)
              .completeSavedUploadInBackground(trackId);
          return;
        }
      } catch (_) {
        // Network hiccup — keep polling silently.
      }
    }

    // Timed out — show the track as-is rather than an error.
    try {
      final track = await repository.getTrackStatus(trackId);
      state = state.copyWith(
        isPolling: false,
        processingStatus: track.status,
        finalTrack: track,
      );
    } catch (_) {
      state = state.copyWith(isPolling: false);
    }
  }

  Future<bool> saveForEdit(String trackId) async {
    if (!_beginSave()) return false;

    try {
      final repository = ref.read(uploadRepositoryProvider);
      final metadata = TrackMetadataMapper.toEntity(state);
      final updated = await repository.updateTrackMetadata(
        trackId: trackId,
        metadata: metadata,
      );
      state = state.copyWith(
        isSaving: false,
        processingStatus: updated.status,
        finalTrack: updated,
      );
      return true;
    } catch (error, stackTrace) {
      _failSave(
        error,
        stackTrace,
        fallback: 'We could not save those track changes. Please try again.',
      );
      return false;
    }
  }

  bool _beginSave() {
    final effectiveState = _effectiveAvailabilityStateForCurrentTier();
    final error = TrackMetadataValidator.validateForSave(effectiveState);
    if (error != null) {
      state = state.copyWith(error: error);
      return false;
    }
    state = effectiveState.copyWith(
      isSaving: true,
      isPolling: false,
      processingStatus: UploadStatus.idle,
      finalTrack: null,
      error: null,
    );
    return true;
  }

  TrackMetadataState _effectiveAvailabilityStateForCurrentTier() {
    final isPro = ref.read(uploadProvider).quota?.isUnlimited ?? false;
    if (isPro) return state;

    return state.copyWith(
      availabilityType: 'worldwide',
      availabilityRegionsText: '',
      error: null,
    );
  }

  void _failSave(
    Object error,
    StackTrace stackTrace, {
    required String fallback,
  }) {
    logUploadError('save track metadata', error, stackTrace);
    state = state.copyWith(
      isSaving: false,
      isPolling: false,
      processingStatus: UploadStatus.failed,
      error: userFriendlyUploadError(error, fallback: fallback),
    );
  }
}

final trackMetadataProvider =
    NotifierProvider<TrackMetadataNotifier, TrackMetadataState>(
      TrackMetadataNotifier.new,
    );
