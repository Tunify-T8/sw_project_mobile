import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_status.dart';
import 'track_metadata_state.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';

class TrackMetadataNotifier extends Notifier<TrackMetadataState> {
  @override
  TrackMetadataState build() {
    final primaryArtist = ref.read(currentArtistNameProvider);

    return TrackMetadataState(
      artists: [primaryArtist],
    );
  }

  void prepareForNewUpload(String fileName) {
    final primaryArtist = ref.read(currentArtistNameProvider);

    state = TrackMetadataState(
      title: fileName,
      artists: [primaryArtist],
    );
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setGenreCategory(String value) {
    state = state.copyWith(genreCategory: value);
  }

  void setGenreSubGenre(String value) {
    state = state.copyWith(genreSubGenre: value);
  }

  void setTagsText(String value) {
    state = state.copyWith(tagsText: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setPrivacy(String value) {
    state = state.copyWith(privacy: value);
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

    final updatedArtists = state.artists
        .where((element) => element != artist)
        .toList();

    state = state.copyWith(
      artists: updatedArtists,
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
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  void saveMetadataAndProcessInBackground(String trackId) {
    unawaited(_saveMetadataAndProcess(trackId));
  }

  Future<void> _saveMetadataAndProcess(String trackId) async {
    if (state.title.trim().isEmpty) {
      state = state.copyWith(
        error: 'Title is required.',
      );
      return;
    }

    if (state.genreSubGenre.trim().isEmpty) {
      state = state.copyWith(
        error: 'Genre is required.',
      );
      return;
    }

    if (state.artists.isEmpty) {
      state = state.copyWith(
        error: 'At least one artist is required.',
      );
      return;
    }

    state = state.copyWith(
      isSaving: true,
      isPolling: false,
      processingStatus: UploadStatus.idle,
      finalTrack: null,
      error: null,
    );

    try {
      final repository = ref.read(uploadRepositoryProvider);

      final metadata = TrackMetadata(
        title: state.title.trim(),
        genreCategory: state.genreCategory.trim(),
        genreSubGenre: state.genreSubGenre.trim(),
        tags: state.tagsText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        description: state.description.trim(),
        privacy: state.privacy,
        artists: state.artists,
        artworkPath: state.artworkPath,
      );

      final processingTrack = await repository.finalizeMetadata(
        trackId: trackId,
        metadata: metadata,
      );

      state = state.copyWith(
        isSaving: false,
        isPolling: true,
        processingStatus: processingTrack.status,
      );

      final finalTrack = await repository.waitUntilProcessed(trackId);

      state = state.copyWith(
        isPolling: false,
        processingStatus: finalTrack.status,
        finalTrack: finalTrack,
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
