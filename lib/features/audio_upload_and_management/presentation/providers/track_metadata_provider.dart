import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_status.dart';
import 'track_metadata_state.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';

class TrackMetadataNotifier extends Notifier<TrackMetadataState> {
  @override
  TrackMetadataState build() {
    return const TrackMetadataState();
  }

  void initializeSuggestedTitle(String fileName) {
    if (state.title.isNotEmpty) {
      return;
    }

    state = state.copyWith(
      title: fileName,
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

  Future<bool> saveMetadataAndWait(String trackId) async {
    if (state.title.trim().isEmpty) {
      state = state.copyWith(
        error: 'Title is required.',
      );
      return false;
    }

    if (state.genreSubGenre.trim().isEmpty) {
      state = state.copyWith(
        error: 'Genre is required.',
      );
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      error: null,
    );

    try {
      final repository = ref.read(uploadRepositoryProvider);
      final currentArtistName = ref.read(currentArtistNameProvider);

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
        artists: [currentArtistName],
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

      return finalTrack.status == UploadStatus.finished;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isPolling: false,
        processingStatus: UploadStatus.failed,
        error: e.toString(),
      );
      return false;
    }
  }
}

final trackMetadataProvider =
    NotifierProvider<TrackMetadataNotifier, TrackMetadataState>(
  TrackMetadataNotifier.new,
);