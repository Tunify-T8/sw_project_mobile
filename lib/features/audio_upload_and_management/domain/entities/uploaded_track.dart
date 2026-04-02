// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: upload_mappers, real_upload_repository_impl, and 11 more upload files.
// Concerns: Multi-format support; Transcoding logic.
import 'upload_status.dart';

class UploadedTrack {
  final String trackId;
  final UploadStatus status;
  final String? audioUrl;
  final String? waveformUrl;
  final String? title;
  final String? description;
  final String? privacy;
  final String? artworkUrl;
  final int? durationSeconds;
  final List<String> artists;
  final List<String>? tags;
  final String? genreCategory;
  final String? genreSubGenre;
  final String? recordLabel;
  final String? publisher;
  final String? isrc;
  final String? pLine;
  final bool? contentWarning;
  final DateTime? scheduledReleaseDate;
  final bool? allowDownloads;
  final bool? offlineListening;
  final bool? includeInRss;
  final bool? displayEmbedCode;
  final bool? appPlaybackEnabled;
  final String? availabilityType;
  final List<String>? availabilityRegions;
  final String? licensing;
  final String? errorCode;
  final String? errorMessage;

  const UploadedTrack({
    required this.trackId,
    required this.status,
    this.audioUrl,
    this.waveformUrl,
    this.title,
    this.description,
    this.privacy,
    this.artworkUrl,
    this.durationSeconds,
    this.artists = const [],
    this.tags,
    this.genreCategory,
    this.genreSubGenre,
    this.recordLabel,
    this.publisher,
    this.isrc,
    this.pLine,
    this.contentWarning,
    this.scheduledReleaseDate,
    this.allowDownloads,
    this.offlineListening,
    this.includeInRss,
    this.displayEmbedCode,
    this.appPlaybackEnabled,
    this.availabilityType,
    this.availabilityRegions,
    this.licensing,
    this.errorCode,
    this.errorMessage,
  });

  UploadedTrack copyWith({
    String? trackId,
    UploadStatus? status,
    String? audioUrl,
    String? waveformUrl,
    String? title,
    String? description,
    String? privacy,
    String? artworkUrl,
    int? durationSeconds,
    List<String>? artists,
    List<String>? tags,
    String? genreCategory,
    String? genreSubGenre,
    String? recordLabel,
    String? publisher,
    String? isrc,
    String? pLine,
    bool? contentWarning,
    DateTime? scheduledReleaseDate,
    bool? allowDownloads,
    bool? offlineListening,
    bool? includeInRss,
    bool? displayEmbedCode,
    bool? appPlaybackEnabled,
    String? availabilityType,
    List<String>? availabilityRegions,
    String? licensing,
    String? errorCode,
    String? errorMessage,
  }) {
    return UploadedTrack(
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      waveformUrl: waveformUrl ?? this.waveformUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      artists: artists ?? this.artists,
      tags: tags ?? this.tags,
      genreCategory: genreCategory ?? this.genreCategory,
      genreSubGenre: genreSubGenre ?? this.genreSubGenre,
      recordLabel: recordLabel ?? this.recordLabel,
      publisher: publisher ?? this.publisher,
      isrc: isrc ?? this.isrc,
      pLine: pLine ?? this.pLine,
      contentWarning: contentWarning ?? this.contentWarning,
      scheduledReleaseDate: scheduledReleaseDate ?? this.scheduledReleaseDate,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      offlineListening: offlineListening ?? this.offlineListening,
      includeInRss: includeInRss ?? this.includeInRss,
      displayEmbedCode: displayEmbedCode ?? this.displayEmbedCode,
      appPlaybackEnabled: appPlaybackEnabled ?? this.appPlaybackEnabled,
      availabilityType: availabilityType ?? this.availabilityType,
      availabilityRegions: availabilityRegions ?? this.availabilityRegions,
      licensing: licensing ?? this.licensing,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
