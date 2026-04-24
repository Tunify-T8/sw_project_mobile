// Upload Feature Guide:
// Purpose: DTO model that represents upload-related request or response data at the API boundary.
// Used by: upload_api, upload_mappers
// Concerns: Transcoding logic.
import 'genre_parsing.dart';

part 'track_response_nested_dto.dart';

class TrackResponseDto {
  final String trackId;
  final String status;
  final String? title;
  final String? description;
  final String? genre;
  final String? genreCategory;
  final String? genreSubGenre;
  final List<String>? tags;
  final List<String>? artists;
  final int? durationSeconds;
  final String? privacy;
  final String? scheduledReleaseDate;
  final AvailabilityDto? availability;
  final LicensingDto? licensing;
  final PermissionsDto? permissions;
  final String? recordLabel;
  final String? publisher;
  final String? isrc;
  final String? pLine;
  final bool? contentWarning;
  final String? audioUrl;
  final String? waveformUrl;
  final String? artworkUrl;
  final String? createdAt;
  final String? updatedAt;
  final AudioMetadataDto? audioMetadata;
  final String? privateToken;
  final String? errorCode;
  final String? errorMessage;
  final Map<String, dynamic>? rawJson;

  TrackResponseDto({
    required this.trackId,
    required this.status,
    this.title,
    this.description,
    this.genre,
    this.genreCategory,
    this.genreSubGenre,
    this.tags,
    this.artists,
    this.durationSeconds,
    this.privacy,
    this.scheduledReleaseDate,
    this.availability,
    this.licensing,
    this.permissions,
    this.recordLabel,
    this.publisher,
    this.isrc,
    this.pLine,
    this.contentWarning,
    this.audioUrl,
    this.waveformUrl,
    this.artworkUrl,
    this.createdAt,
    this.updatedAt,
    this.audioMetadata,
    this.privateToken,
    this.errorCode,
    this.errorMessage,
    this.rawJson,
  });

  factory TrackResponseDto.fromJson(Map<String, dynamic> json) {
    final error = json['error'];
    final availabilityJson = json['availability'];
    final licensingJson = json['licensing'];
    final permissionsJson = json['permissions'];
    final audioMetadataJson = json['audioMetadata'];

    final rawTrackId = (json['trackId'] ?? json['id'] ?? '') as Object;
    final trackId = rawTrackId.toString();

    final rawStatus =
        (json['status'] ?? json['transcodingStatus'] ?? 'processing') as Object;
    final status = rawStatus.toString();

    final parsedGenre = parseUploadGenre(
      json['genre'],
      fallbackCategory: json['genreCategory']?.toString(),
      fallbackSubGenre: json['genreSubGenre']?.toString(),
    );

    List<String>? artists;
    final rawArtists = json['artists'];
    final rawArtist = json['artist'];
    if (rawArtists is List) {
      artists = rawArtists
          .map((e) {
            if (e is String) return e.trim();
            if (e is Map<String, dynamic>) {
              return (e['name'] ?? e['username'] ?? e['userId'] ?? '')
                  .toString()
                  .trim();
            }
            return e.toString().trim();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (rawArtist is String && rawArtist.trim().isNotEmpty) {
      artists = [rawArtist.trim()];
    } else if (rawArtist is Map<String, dynamic>) {
      final artistValue =
          (rawArtist['name'] ?? rawArtist['username'] ?? rawArtist['id'])
              ?.toString()
              .trim();
      if (artistValue != null && artistValue.isNotEmpty) {
        artists = [artistValue];
      }
    }

    return TrackResponseDto(
      trackId: trackId,
      status: status,
      title: json['title'] as String?,
      description: json['description'] as String?,
      genre: parsedGenre.normalized,
      genreCategory: parsedGenre.category,
      genreSubGenre: parsedGenre.subGenre,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      artists: artists,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      privacy: json['privacy'] as String?,
      scheduledReleaseDate: json['scheduledReleaseDate'] as String?,
      availability: availabilityJson is Map<String, dynamic>
          ? AvailabilityDto.fromJson(availabilityJson)
          : null,
      licensing: licensingJson is Map<String, dynamic>
          ? LicensingDto.fromJson(licensingJson)
          : null,
      permissions: permissionsJson is Map<String, dynamic>
          ? PermissionsDto.fromJson(permissionsJson)
          : null,
      recordLabel: json['recordLabel'] as String?,
      publisher: json['publisher'] as String?,
      isrc: json['isrc'] as String?,
      pLine: json['pLine'] as String?,
      contentWarning: json['contentWarning'] as bool?,
      audioUrl: json['audioUrl'] as String?,
      waveformUrl: json['waveformUrl'] as String?,
      artworkUrl: (json['artworkUrl'] ?? json['thumbnailUrl']) as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      audioMetadata: audioMetadataJson is Map<String, dynamic>
          ? AudioMetadataDto.fromJson(audioMetadataJson)
          : null,
      privateToken: (json['privateToken'] ?? json['private_token']) as String?,
      errorCode: error is Map<String, dynamic>
          ? error['code'] as String?
          : null,
      errorMessage: error is Map<String, dynamic>
          ? error['message'] as String?
          : null,
      rawJson: json,
    );
  }
}
