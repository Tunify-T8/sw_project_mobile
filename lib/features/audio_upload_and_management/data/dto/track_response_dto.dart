// Upload Feature Guide:
// Purpose: DTO model that represents upload-related request or response data at the API boundary.
// Used by: upload_api, upload_mappers
// Concerns: Transcoding logic.
part 'track_response_nested_dto.dart';

class TrackResponseDto {
  final String trackId;
  final String status;
  final String? title;
  final String? description;
  final String? genre;
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
  final String? errorCode;
  final String? errorMessage;

  TrackResponseDto({
    required this.trackId,
    required this.status,
    this.title,
    this.description,
    this.genre,
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
    this.errorCode,
    this.errorMessage,
  });

  factory TrackResponseDto.fromJson(Map<String, dynamic> json) {
    final error = json['error'];
    final availabilityJson = json['availability'];
    final licensingJson = json['licensing'];
    final permissionsJson = json['permissions'];
    final audioMetadataJson = json['audioMetadata'];

    // `trackId` may come as 'trackId' (finalize/getTrack) or already
    // normalised from 'id' by UploadApi._normalizeTrackJson.
    final rawTrackId = (json['trackId'] ?? json['id'] ?? '') as Object;
    final trackId = rawTrackId.toString();

    // `status` may come as 'status' or already normalised from
    // 'transcodingStatus' by UploadApi._normalizeTrackJson.
    final rawStatus =
        (json['status'] ?? json['transcodingStatus'] ?? 'processing') as Object;
    final status = rawStatus.toString();

    // genre can be a String (PATCH response) or a nested map (GET :id)
    String? genre;
    final rawGenre = json['genre'];
    if (rawGenre is String) {
      genre = rawGenre;
    } else if (rawGenre is Map<String, dynamic>) {
      genre = rawGenre['category'] as String? ?? rawGenre['label'] as String?;
    }

    // artists from backend is List<TrackArtist> objects, not plain strings
    List<String>? artists;
    final rawArtists = json['artists'];
    if (rawArtists is List) {
      artists = rawArtists.map((e) {
        if (e is String) return e;
        if (e is Map<String, dynamic>) {
          return (e['userId'] ?? e['name'] ?? e['username'] ?? '').toString();
        }
        return e.toString();
      }).toList();
    }

    return TrackResponseDto(
      trackId: trackId,
      status: status,
      title: json['title'] as String?,
      description: json['description'] as String?,
      genre: genre,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      artists: artists,
      durationSeconds: json['durationSeconds'] as int?,
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
      errorCode: error is Map<String, dynamic>
          ? error['code'] as String?
          : null,
      errorMessage: error is Map<String, dynamic>
          ? error['message'] as String?
          : null,
    );
  }
}
