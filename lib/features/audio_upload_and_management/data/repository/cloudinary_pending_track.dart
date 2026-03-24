// Upload Feature Guide:
// Purpose: Intermediate working model for a Cloudinary-backed track before it is fully stored as an UploadItem.
// Used by: cloudinary_upload_artwork_resolver, cloudinary_upload_mapper, cloudinary_upload_workflow
// Concerns: Multi-format support.
import '../../domain/entities/upload_item.dart';

class PendingCloudinaryTrack {
  const PendingCloudinaryTrack({
    required this.trackId,
    required this.createdAt,
    this.ownerUserId,
    this.audioUrl,
    this.audioPublicId,
    this.waveformUrl,
    this.waveformBars,
    this.artworkUrl,
    this.localArtworkPath,
    this.localFilePath,
    this.durationSeconds = 0,
    this.title,
    this.description,
    this.privacy = 'public',
    this.artists = const [],
    this.tags = const [],
    this.genreCategory = '',
    this.genreSubGenre = '',
    this.recordLabel = '',
    this.publisher = '',
    this.isrc = '',
    this.pLine = '',
    this.contentWarning = false,
    this.scheduledReleaseDate,
    this.allowDownloads = false,
    this.offlineListening = true,
    this.includeInRss = true,
    this.displayEmbedCode = true,
    this.appPlaybackEnabled = true,
    this.availabilityType = 'worldwide',
    this.availabilityRegions = const [],
    this.licensing = 'all_rights_reserved',
  });

  final String trackId;
  final DateTime createdAt;
  final String? ownerUserId;
  final String? audioUrl;
  final String? audioPublicId;
  final String? waveformUrl;
  final List<double>? waveformBars;
  final String? artworkUrl;
  final String? localArtworkPath;
  final String? localFilePath;
  final int durationSeconds;
  final String? title;
  final String? description;
  final String privacy;
  final List<String> artists;
  final List<String> tags;
  final String genreCategory;
  final String genreSubGenre;
  final String recordLabel;
  final String publisher;
  final String isrc;
  final String pLine;
  final bool contentWarning;
  final DateTime? scheduledReleaseDate;
  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;
  final String availabilityType;
  final List<String> availabilityRegions;
  final String licensing;

  static PendingCloudinaryTrack? maybeFromUploadItem(
    UploadItem? item, {
    String? ownerUserId,
  }) {
    if (item == null) return null;

    return PendingCloudinaryTrack(
      trackId: item.id,
      createdAt: item.createdAt,
      ownerUserId: ownerUserId,
      audioUrl: item.audioUrl,
      waveformUrl: item.waveformUrl,
      waveformBars: item.waveformBars,
      artworkUrl: item.artworkUrl,
      localArtworkPath: item.localArtworkPath,
      localFilePath: item.localFilePath,
      durationSeconds: item.durationSeconds,
      title: item.title,
      description: item.description,
      privacy: item.visibility == UploadVisibility.public
          ? 'public'
          : 'private',
      artists: item.artistDisplay
          .split(',')
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList(),
      tags: item.tags,
      genreCategory: item.genreCategory,
      genreSubGenre: item.genreSubGenre,
      recordLabel: item.recordLabel,
      publisher: item.publisher,
      isrc: item.isrc,
      pLine: item.pLine,
      contentWarning: item.isExplicit,
      scheduledReleaseDate: item.scheduledReleaseDate,
      allowDownloads: item.allowDownloads,
      offlineListening: item.offlineListening,
      includeInRss: item.includeInRss,
      displayEmbedCode: item.displayEmbedCode,
      appPlaybackEnabled: item.appPlaybackEnabled,
      availabilityType: item.availabilityType,
      availabilityRegions: item.availabilityRegions,
      licensing: item.licensing,
    );
  }

  PendingCloudinaryTrack copyWith({
    String? ownerUserId,
    String? audioUrl,
    String? audioPublicId,
    String? waveformUrl,
    List<double>? waveformBars,
    String? artworkUrl,
    String? localArtworkPath,
    String? localFilePath,
    int? durationSeconds,
    String? title,
    String? description,
    String? privacy,
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
  }) {
    return PendingCloudinaryTrack(
      trackId: trackId,
      createdAt: createdAt,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      audioUrl: audioUrl ?? this.audioUrl,
      audioPublicId: audioPublicId ?? this.audioPublicId,
      waveformUrl: waveformUrl ?? this.waveformUrl,
      waveformBars: waveformBars ?? this.waveformBars,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      localFilePath: localFilePath ?? this.localFilePath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      title: title ?? this.title,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
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
    );
  }
}
