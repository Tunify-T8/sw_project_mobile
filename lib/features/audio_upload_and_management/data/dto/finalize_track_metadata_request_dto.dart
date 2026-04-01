import 'package:dio/dio.dart';

import '../../domain/entities/track_metadata.dart';

part 'finalize_track_metadata_request_dto_helpers.dart';

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

    final genreValue = _buildGenreValue(
      category: normalizedCategory,
      subGenre: normalizedSubGenre,
    );

    return FinalizeTrackMetadataRequestDto(
      trackId: trackId,
      title: metadata.title,
      genre: genreValue,
      tags: metadata.tags,
      description: metadata.description,
      privacy: metadata.privacy,
      artists: metadata.artists
          .map((artist) => artist.trim())
          .where((artist) => artist.isNotEmpty)
          .toList(),
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

  bool get hasLocalArtwork =>
      artworkPath != null &&
      artworkPath!.isNotEmpty &&
      !artworkPath!.startsWith('http');
}
