import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/upload_genre.dart';
import '../../domain/entities/upload_status.dart';
import 'track_metadata_mapper.dart';
import 'track_metadata_state.dart';
import 'track_metadata_validator.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';

class TrackMetadataNotifier extends Notifier<TrackMetadataState> {
  @override
  TrackMetadataState build() {
    return TrackMetadataState(
      artists: [_primaryArtist],
    );
  }

  String get _primaryArtist => ref.read(currentArtistNameProvider);

  void prepareForNewUpload(String fileName) {
    state = TrackMetadataState(
      title: fileName,
      artists: [_primaryArtist],
    );
  }

  void setTitle(String value) {
    state = state.copyWith(title: value, error: null);
  }

  void setGenreCategory(String value) {
    state = state.copyWith(genreCategory: value, error: null);
  }

  void setGenreSubGenre(String value) {
    state = state.copyWith(genreSubGenre: value, error: null);
  }

  void setGenre(UploadGenre genre) {
    state = state.copyWith(
      genreCategory: genre.categoryValue.isEmpty ? 'music' : genre.categoryValue,
      genreSubGenre: genre.subGenre,
      error: null,
    );
  }

  void setTagsText(String value) {
    state = state.copyWith(tagsText: value, error: null);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value, error: null);
  }

  void setPrivacy(String value) {
    state = state.copyWith(privacy: value, error: null);
  }

  void addArtist(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return;
    }

    final alreadyExists = state.artists.any(
      (artist) => artist.toLowerCase() == trimmed.toLowerCase(),
    );

    if (alreadyExists) {
      return;
    }

    state = state.copyWith(
      artists: [...state.artists, trimmed],
      error: null,
    );
  }

  void removeArtist(String artist) {
    if (state.artists.length == 1) {
      return;
    }

    state = state.copyWith(
      artists: state.artists.where((value) => value != artist).toList(),
      error: null,
    );
  }

  Future<void> pickArtwork({bool fromCamera = false}) async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final path = await picker.pickArtworkImage(fromCamera: fromCamera);

      if (path == null) {
        return;
      }

      state = state.copyWith(
        artworkPath: path,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> saveMetadataAndProcessInBackground(String trackId) async {
    final validationError = TrackMetadataValidator.validateForSave(state);

    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      isPolling: false,
      processingStatus: UploadStatus.idle,
      finalTrack: null,
      error: null,
    );

    unawaited(_saveMetadataAndProcess(trackId));
    return true;
  }

  Future<void> _saveMetadataAndProcess(String trackId) async {
    try {
      final repository = ref.read(uploadRepositoryProvider);
      final metadata = TrackMetadataMapper.toEntity(state);

      final processingTrack = await repository.finalizeMetadata(
        trackId: trackId,
        metadata: metadata,
      );

      state = state.copyWith(
        isSaving: false,
        isPolling: true,
        processingStatus: processingTrack.status,
        error: null,
      );

      final finalTrack = await repository.waitUntilProcessed(trackId);

      state = state.copyWith(
        isPolling: false,
        processingStatus: finalTrack.status,
        finalTrack: finalTrack,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isPolling: false,
        processingStatus: UploadStatus.failed,
        error: e.toString(),
      );
    }
  }
}

final trackMetadataProvider =
    NotifierProvider<TrackMetadataNotifier, TrackMetadataState>(
  TrackMetadataNotifier.new,
);