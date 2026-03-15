import 'package:dio/dio.dart';
import '../../domain/entities/track_metadata.dart';

class FinalizeTrackMetadataRequestDto {
  final String trackId;
  final String title;
  final String genreCategory;
  final String genreSubGenre;
  final List<String> tags;
  final String description;
  final String privacy;
  final List<String> artists;
  final String? artworkPath;

  final String recordLabel;
  final String publisher;
  final String isrc;
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

  FinalizeTrackMetadataRequestDto({
    required this.trackId,
    required this.title,
    required this.genreCategory,
    required this.genreSubGenre,
    required this.tags,
    required this.description,
    required this.privacy,
    required this.artists,
    this.artworkPath,

    required this.recordLabel,
    required this.publisher,
    required this.isrc,
    required this.contentWarning,
    required this.scheduledReleaseDate,
    required this.allowDownloads,
    required this.offlineListening,
    required this.includeInRss,
    required this.displayEmbedCode,
    required this.appPlaybackEnabled,
    required this.availabilityType,
    required this.availabilityRegions,
    required this.licensing,
  });

  factory FinalizeTrackMetadataRequestDto.fromEntity({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    return FinalizeTrackMetadataRequestDto(
      trackId: trackId,
      title: metadata.title,
      genreCategory: metadata.genreCategory,
      genreSubGenre: metadata.genreSubGenre,
      tags: metadata.tags,
      description: metadata.description,
      privacy: metadata.privacy,
      artists: metadata.artists,
      artworkPath: metadata.artworkPath,
      recordLabel: metadata.recordLabel,
      publisher: metadata.publisher,
      isrc: metadata.isrc,
      contentWarning: metadata.contentWarning,
      scheduledReleaseDate: metadata.scheduledReleaseDate,
      allowDownloads: metadata.allowDownloads,
      offlineListening: metadata.offlineListening,
      includeInRss: metadata.includeInRss,
      displayEmbedCode: metadata.displayEmbedCode,
      appPlaybackEnabled: metadata.appPlaybackEnabled,
      availabilityType: metadata.availabilityType,
      availabilityRegions: metadata.availabilityRegions,
      licensing: metadata.licensing,
    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'trackId': trackId,
      'title': title,
      'genre[category]': genreCategory,
      'genre[subGenre]': genreSubGenre,
      'tags': tags,
      'description': description,
      'privacy': privacy,
      'artists': artists,

      'recordLabel': recordLabel,
      'publisher': publisher,
      'isrc': isrc,
      'contentWarning': contentWarning,
      if (scheduledReleaseDate != null)
        'scheduledReleaseDate': scheduledReleaseDate!.toIso8601String(),
      'permissions[allowDownloads]': allowDownloads,
      'permissions[offlineListening]': offlineListening,
      'permissions[includeInRss]': includeInRss,
      'permissions[displayEmbedCode]': displayEmbedCode,
      'permissions[appPlaybackEnabled]': appPlaybackEnabled,
      'availability[type]': availabilityType,
      'availability[regions]': availabilityRegions,
      'licensing': licensing,

      if (artworkPath != null && artworkPath!.isNotEmpty)
        'artwork': await MultipartFile.fromFile(artworkPath!),
    });
  }
}
