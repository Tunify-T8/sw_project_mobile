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

  final String recordLabel;
  final String publisher;
  final String isrc;
  final String pLine;
  final bool hasScheduledRelease;
  final DateTime? scheduledReleaseDate;
  final bool contentWarning;

  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;
  final String availabilityType;
  final String availabilityRegionsText;
  final String licensing;

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
    this.recordLabel = '',
    this.publisher = '',
    this.isrc = '',
    this.pLine = '',
    this.hasScheduledRelease = false,
    this.scheduledReleaseDate,
    this.contentWarning = false,
    this.allowDownloads = false,
    this.offlineListening = true,
    this.includeInRss = true,
    this.displayEmbedCode = true,
    this.appPlaybackEnabled = true,
    this.availabilityType = 'worldwide',
    this.availabilityRegionsText = '',
    this.licensing = 'all_rights_reserved',
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
    String? recordLabel,
    String? publisher,
    String? isrc,
    String? pLine,
    bool? hasScheduledRelease,
    DateTime? scheduledReleaseDate,
    bool? contentWarning,
    bool? allowDownloads,
    bool? offlineListening,
    bool? includeInRss,
    bool? displayEmbedCode,
    bool? appPlaybackEnabled,
    String? availabilityType,
    String? availabilityRegionsText,
    String? licensing,
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
      recordLabel: recordLabel ?? this.recordLabel,
      publisher: publisher ?? this.publisher,
      isrc: isrc ?? this.isrc,
      pLine: pLine ?? this.pLine,
      hasScheduledRelease: hasScheduledRelease ?? this.hasScheduledRelease,
      scheduledReleaseDate: scheduledReleaseDate ?? this.scheduledReleaseDate,
      contentWarning: contentWarning ?? this.contentWarning,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      offlineListening: offlineListening ?? this.offlineListening,
      includeInRss: includeInRss ?? this.includeInRss,
      displayEmbedCode: displayEmbedCode ?? this.displayEmbedCode,
      appPlaybackEnabled: appPlaybackEnabled ?? this.appPlaybackEnabled,
      availabilityType: availabilityType ?? this.availabilityType,
      availabilityRegionsText:
          availabilityRegionsText ?? this.availabilityRegionsText,
      licensing: licensing ?? this.licensing,
      isSaving: isSaving ?? this.isSaving,
      isPolling: isPolling ?? this.isPolling,
      processingStatus: processingStatus ?? this.processingStatus,
      finalTrack: finalTrack ?? this.finalTrack,
      error: error,
    );
  }
}