import 'package:dio/dio.dart';
import '../../domain/entities/track_metadata.dart';

class FinalizeTrackMetadataRequestDto {
  final String trackId;
  final String title;
  final String genre;
  final List<String> tags;
  final String description;
  final String privacy;
  final List<String> artists;
  final String? artworkPath;

  final String recordLabel;
  final String publisher;
  final String isrc;
  final String pLine;
  final bool contentWarning;
  final DateTime? scheduledReleaseDate;

  final bool enableDirectDownloads;
  final bool enableOfflineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool enableAppPlayback;

  final String availabilityType;
  final List<String> availabilityRegions;

  final String licensingType;
  final bool allowAttribution;
  final bool nonCommercial;
  final bool noDerivatives;
  final bool shareAlike;

  FinalizeTrackMetadataRequestDto({
    required this.trackId,
    required this.title,
    required this.genre,
    required this.tags,
    required this.description,
    required this.privacy,
    required this.artists,
    this.artworkPath,
    required this.recordLabel,
    required this.publisher,
    required this.isrc,
    required this.pLine,
    required this.contentWarning,
    required this.scheduledReleaseDate,
    required this.enableDirectDownloads,
    required this.enableOfflineListening,
    required this.includeInRss,
    required this.displayEmbedCode,
    required this.enableAppPlayback,
    required this.availabilityType,
    required this.availabilityRegions,
    required this.licensingType,
    required this.allowAttribution,
    required this.nonCommercial,
    required this.noDerivatives,
    required this.shareAlike,
  });

  factory FinalizeTrackMetadataRequestDto.fromEntity({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    final normalizedCategory = metadata.genreCategory.trim().toLowerCase();
    final normalizedSubGenre = metadata.genreSubGenre
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_');

    final genreValue =
        '${normalizedCategory.isEmpty ? 'music' : normalizedCategory}_${normalizedSubGenre.isEmpty ? 'hiphop' : normalizedSubGenre}';

    return FinalizeTrackMetadataRequestDto(
      trackId: trackId,
      title: metadata.title,
      genre: genreValue,
      tags: metadata.tags,
      description: metadata.description,
      privacy: metadata.privacy,
      artists: metadata.artists,
      artworkPath: metadata.artworkPath,
      recordLabel: metadata.recordLabel,
      publisher: metadata.publisher,
      isrc: metadata.isrc,
      pLine: metadata.pLine.isNotEmpty
          ? metadata.pLine
          : '2026 SoundCloud Clone',
      contentWarning: metadata.contentWarning,
      scheduledReleaseDate: metadata.scheduledReleaseDate,
      enableDirectDownloads: metadata.allowDownloads,
      enableOfflineListening: metadata.offlineListening,
      includeInRss: metadata.includeInRss,
      displayEmbedCode: metadata.displayEmbedCode,
      enableAppPlayback: metadata.appPlaybackEnabled,
      availabilityType: metadata.availabilityType,
      availabilityRegions: metadata.availabilityRegions,
      licensingType: metadata.licensing,
      allowAttribution: metadata.licensing == 'creative_commons',
      nonCommercial: metadata.licensing == 'creative_commons',
      noDerivatives: false,
      shareAlike: metadata.licensing == 'creative_commons',
    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'trackId': trackId,
      'title': title,
      'genre': genre,
      'tags': tags,
      'description': description,
      'privacy': privacy,
      'artists': artists,
      'recordLabel': recordLabel,
      'publisher': publisher,
      'isrc': isrc,
      'pLine': pLine,
      'contentWarning': contentWarning,
      if (scheduledReleaseDate != null)
        'scheduledReleaseDate': scheduledReleaseDate!.toIso8601String(),
      'availability[type]': availabilityType,
      'availability[regions]': availabilityRegions,
      'licensing[type]': licensingType,
      'licensing[allowAttribution]': allowAttribution,
      'licensing[nonCommercial]': nonCommercial,
      'licensing[noDerivatives]': noDerivatives,
      'licensing[shareAlike]': shareAlike,
      'permissions[enableDirectDownloads]': enableDirectDownloads,
      'permissions[enableOfflineListening]': enableOfflineListening,
      'permissions[includeInRSS]': includeInRss,
      'permissions[displayEmbedCode]': displayEmbedCode,
      'permissions[enableAppPlayback]': enableAppPlayback,
      if (artworkPath != null &&
          artworkPath!.isNotEmpty &&
          !artworkPath!.startsWith('http'))
        'artwork': await MultipartFile.fromFile(artworkPath!),
    });
  }
}
