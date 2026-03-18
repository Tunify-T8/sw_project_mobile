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
      final processing = await repository.finalizeMetadata(
        trackId: trackId,
        metadata: metadata,
      );
      state = state.copyWith(
        isSaving: false,
        isPolling: true,
        processingStatus: processing.status,
      );

      final finalTrack = await repository.waitUntilProcessed(trackId);
      state = state.copyWith(
        isPolling: false,
        processingStatus: finalTrack.status,
        finalTrack: finalTrack,
        error: null,
      );
      return finalTrack.status == UploadStatus.finished;
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
    final error = TrackMetadataValidator.validateForSave(state);
    if (error != null) {
      state = state.copyWith(error: error);
      return false;
    }
    state = state.copyWith(
      isSaving: true,
      isPolling: false,
      processingStatus: UploadStatus.idle,
      finalTrack: null,
      error: null,
    );
    return true;
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
