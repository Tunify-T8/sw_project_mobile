// Upload Feature Guide:
// Purpose: DTO model that represents upload-related request or response data at the API boundary.
// Used by: Consumed across nearby upload data and domain files.
// Concerns: Transcoding logic.
part of 'track_response_dto.dart';

class AvailabilityDto {
  final String type;
  final List<String> regions;

  AvailabilityDto({required this.type, required this.regions});

  factory AvailabilityDto.fromJson(Map<String, dynamic> json) {
    return AvailabilityDto(
      type: (json['type'] as String?) ?? 'worldwide',
      regions:
          (json['regions'] as List?)
              ?.map((entry) => entry.toString())
              .toList() ??
          const [],
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
      enableOfflineListening:
          (json['enableOfflineListening'] as bool?) ?? false,
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
