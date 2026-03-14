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
