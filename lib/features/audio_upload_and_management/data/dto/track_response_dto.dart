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
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      artists: (json['artists'] as List?)?.map((e) => e.toString()).toList(),
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
      errorCode: error is Map<String, dynamic> ? error['code'] as String? : null,
      errorMessage:
          error is Map<String, dynamic> ? error['message'] as String? : null,
    );
  }
}

class AvailabilityDto {
  final String type;
  final List<String> regions;

  AvailabilityDto({
    required this.type,
    required this.regions,
  });

  factory AvailabilityDto.fromJson(Map<String, dynamic> json) {
    return AvailabilityDto(
      type: (json['type'] as String?) ?? 'worldwide',
      regions: (json['regions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class LicensingDto {
  final String type;
  final bool allowAttribution;
  final bool nonCommercial;
  final bool noDerivatives;
  final bool shareAlike;

  LicensingDto({
    required this.type,
    required this.allowAttribution,
    required this.nonCommercial,
    required this.noDerivatives,
    required this.shareAlike,
  });

  factory LicensingDto.fromJson(Map<String, dynamic> json) {
    return LicensingDto(
      type: (json['type'] as String?) ?? 'all_rights_reserved',
      allowAttribution: (json['allowAttribution'] as bool?) ?? false,
      nonCommercial: (json['nonCommercial'] as bool?) ?? false,
      noDerivatives: (json['noDerivatives'] as bool?) ?? false,
      shareAlike: (json['shareAlike'] as bool?) ?? false,
    );
  }
}

class PermissionsDto {
  final bool enableDirectDownloads;
  final bool enableOfflineListening;
  final bool includeInRSS;
  final bool displayEmbedCode;
  final bool enableAppPlayback;
  final bool allowComments;
  final bool showCommentsPublic;
  final bool showInsightsPublic;

  PermissionsDto({
    required this.enableDirectDownloads,
    required this.enableOfflineListening,
    required this.includeInRSS,
    required this.displayEmbedCode,
    required this.enableAppPlayback,
    required this.allowComments,
    required this.showCommentsPublic,
    required this.showInsightsPublic,
  });

  factory PermissionsDto.fromJson(Map<String, dynamic> json) {
    return PermissionsDto(
      enableDirectDownloads: (json['enableDirectDownloads'] as bool?) ?? false,
      enableOfflineListening: (json['enableOfflineListening'] as bool?) ?? false,
      includeInRSS: (json['includeInRSS'] as bool?) ?? false,
      displayEmbedCode: (json['displayEmbedCode'] as bool?) ?? false,
      enableAppPlayback: (json['enableAppPlayback'] as bool?) ?? false,
      allowComments: (json['allowComments'] as bool?) ?? true,
      showCommentsPublic: (json['showCommentsPublic'] as bool?) ?? true,
      showInsightsPublic: (json['showInsightsPublic'] as bool?) ?? false,
    );
  }
}

class AudioMetadataDto {
  final int? bitrateKbps;
  final int? sampleRateHz;
  final String? format;
  final int? fileSizeBytes;

  AudioMetadataDto({
    this.bitrateKbps,
    this.sampleRateHz,
    this.format,
    this.fileSizeBytes,
  });

  factory AudioMetadataDto.fromJson(Map<String, dynamic> json) {
    return AudioMetadataDto(
      bitrateKbps: json['bitrateKbps'] as int?,
      sampleRateHz: json['sampleRateHz'] as int?,
      format: json['format'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int?,
    );
  }
}