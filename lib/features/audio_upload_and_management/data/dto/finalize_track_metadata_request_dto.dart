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
        '${normalizedCategory.isEmpty ? 'music' : normalizedCategory}_'
        '${normalizedSubGenre.isEmpty ? 'hiphop' : normalizedSubGenre}';

    return FinalizeTrackMetadataRequestDto(
      trackId: trackId,
      title: metadata.title,
      genre: genreValue,
      tags: metadata.tags,
      description: metadata.description,
      privacy: metadata.privacy,
      // Only send artists that look like UUIDs — plain display names cause a
      // DB lookup failure (500) on the backend. Empty list is safe.
      artists: metadata.artists
          .where(_looksLikeUuid)
          .toList(),
      artworkPath: metadata.artworkPath,
      recordLabel: metadata.recordLabel,
      publisher: metadata.publisher,
      isrc: metadata.isrc,
      pLine: metadata.pLine.isNotEmpty ? metadata.pLine : '2026 SoundCloud Clone',
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

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  /// Returns a JSON map (for requests without a file attachment) or a
  /// [FormData] (when artwork is being uploaded).
  ///
  /// Why two paths?
  /// multipart/form-data serialises every value as a string.  NestJS
  /// class-validator's @IsBoolean() then rejects "true" / "false" because
  /// they are strings, not booleans.  When there is no artwork we can send
  /// plain JSON where Dart booleans survive as JSON booleans.  When artwork
  /// is present we must use multipart, so we rely on @Transform in the DTO
  /// and send the string representations NestJS expects.

  bool get _hasLocalArtwork =>
      artworkPath != null &&
      artworkPath!.isNotEmpty &&
      !artworkPath!.startsWith('http');

  /// Call this from the API layer.  Returns either a [Map] (JSON body) or
  /// a [FormData] (multipart with artwork).
  Future<dynamic> toRequestBody() async {
    if (_hasLocalArtwork) {
      return _toFormData();
    }
    return _toJson();
  }

  Map<String, dynamic> _toJson() {
    final body = <String, dynamic>{
      'title': title,
      'genre': genre,
      'tags': tags,
      'description': description,
      'privacy': privacy,
      if (artists.isNotEmpty) 'artists': artists,
      'recordLabel': recordLabel,
      'publisher': publisher,
      'isrc': isrc,
      'pLine': pLine,
      'contentWarning': contentWarning,
      'availability': {
        'type': availabilityType,
        'regions': availabilityRegions,
      },
      'licensing': {
        'type': licensingType,
        'allowAttribution': allowAttribution,
        'nonCommercial': nonCommercial,
        'noDerivatives': noDerivatives,
        'shareAlike': shareAlike,
      },
      'permissions': {
        'enableDirectDownloads': enableDirectDownloads,
        'enableOfflineListening': enableOfflineListening,
        'includeInRSS': includeInRss,
        'displayEmbedCode': displayEmbedCode,
        'enableAppPlayback': enableAppPlayback,
        'allowComments': true,
        'showCommentsPublic': true,
        'showInsightsPublic': false,
      },
    };

    if (scheduledReleaseDate != null) {
      body['scheduledReleaseDate'] = scheduledReleaseDate!.toIso8601String();
    }

    return body;
  }

  Future<FormData> _toFormData() async {
    // In multipart, booleans must be sent as 'true'/'false' strings and
    // NestJS needs @Transform(() => ...) decorators to parse them.
    // Arrays must be repeated fields (Dio handles List values correctly).
    final map = <String, dynamic>{
      'title': title,
      'genre': genre,
      'description': description,
      'privacy': privacy,
      'recordLabel': recordLabel,
      'publisher': publisher,
      'isrc': isrc,
      'pLine': pLine,
      // Booleans as strings for multipart
      'contentWarning': contentWarning.toString(),
      'availability[type]': availabilityType,
      'licensing[type]': licensingType,
      'licensing[allowAttribution]': allowAttribution.toString(),
      'licensing[nonCommercial]': nonCommercial.toString(),
      'licensing[noDerivatives]': noDerivatives.toString(),
      'licensing[shareAlike]': shareAlike.toString(),
      'permissions[enableDirectDownloads]': enableDirectDownloads.toString(),
      'permissions[enableOfflineListening]': enableOfflineListening.toString(),
      'permissions[includeInRSS]': includeInRss.toString(),
      'permissions[displayEmbedCode]': displayEmbedCode.toString(),
      'permissions[enableAppPlayback]': enableAppPlayback.toString(),
      'permissions[allowComments]': 'true',
      'permissions[showCommentsPublic]': 'true',
      'permissions[showInsightsPublic]': 'false',
      // Arrays — Dio repeats the key for each element
      if (tags.isNotEmpty) 'tags': tags,
      if (artists.isNotEmpty) 'artists': artists,
      if (availabilityRegions.isNotEmpty) 'availability[regions]': availabilityRegions,
      'artwork': await MultipartFile.fromFile(artworkPath!),
    };

    if (scheduledReleaseDate != null) {
      map['scheduledReleaseDate'] = scheduledReleaseDate!.toIso8601String();
    }

    return FormData.fromMap(map);
  }

  static bool _looksLikeUuid(String s) {
    // Simple UUID v4 shape check — 8-4-4-4-12 hex chars
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidPattern.hasMatch(s);
  }
}