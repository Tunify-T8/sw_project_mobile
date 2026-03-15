import '../../domain/entities/upload_genre_model.dart';
//import '../../domain/entities/upload_genres.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';

class TrackMetadataState {
  final String title;
  final String genreCategory;
  final String genreSubGenre;
  final String tagsText;
  final String description;
  final String privacy;
  final List<String> artists;
  final String? artworkPath;

  final bool isSaving;
  final bool isPolling;
  final UploadStatus processingStatus;
  final UploadedTrack? finalTrack;
  final String? error;

  const TrackMetadataState({
    this.title = '',
    this.genreCategory = 'music',
    this.genreSubGenre = '',
    this.tagsText = '',
    this.description = '',
    this.privacy = 'public',
    this.artists = const [],
    this.artworkPath,
    this.isSaving = false,
    this.isPolling = false,
    this.processingStatus = UploadStatus.idle,
    this.finalTrack,
    this.error,
  });

  UploadGenre get selectedGenre => UploadGenres.fromValues(
        category: genreCategory,
        subGenre: genreSubGenre,
      );

  bool get hasTitle => title.trim().isNotEmpty;

  bool get hasGenre => genreSubGenre.trim().isNotEmpty;

  bool get hasArtwork => artworkPath != null && artworkPath!.trim().isNotEmpty;

  bool get hasDescription => description.trim().isNotEmpty;

  int get completedChecklistItems {
    int count = 0;

    if (hasTitle) count++;
    if (hasGenre) count++;
    if (hasArtwork) count++;
    if (hasDescription) count++;

    return count;
  }

  double get checklistProgress => completedChecklistItems / 4;

  bool get isBusyInBackground {
    return isSaving ||
        isPolling ||
        processingStatus == UploadStatus.processing;
  }

  TrackMetadataState copyWith({
    String? title,
    String? genreCategory,
    String? genreSubGenre,
    String? tagsText,
    String? description,
    String? privacy,
    List<String>? artists,
    String? artworkPath,
    bool? isSaving,
    bool? isPolling,
    UploadStatus? processingStatus,
    UploadedTrack? finalTrack,
    String? error,
  }) {
    return TrackMetadataState(
      title: title ?? this.title,
      genreCategory: genreCategory ?? this.genreCategory,
      genreSubGenre: genreSubGenre ?? this.genreSubGenre,
      tagsText: tagsText ?? this.tagsText,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      artists: artists ?? this.artists,
      artworkPath: artworkPath ?? this.artworkPath,
      isSaving: isSaving ?? this.isSaving,
      isPolling: isPolling ?? this.isPolling,
      processingStatus: processingStatus ?? this.processingStatus,
      finalTrack: finalTrack ?? this.finalTrack,
      error: error,
    );
  }
}