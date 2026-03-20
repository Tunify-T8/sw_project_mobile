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

    return TrackResponseDto(
      trackId: json['trackId'] as String,
      status: json['status'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      genre: json['genre'] as String?,
      tags: (json['tags'] as List?)?.map((entry) => entry.toString()).toList(),
      artists: (json['artists'] as List?)
          ?.map((entry) => entry.toString())
          .toList(),
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
      artworkUrl: json['artworkUrl'] as String?,
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
