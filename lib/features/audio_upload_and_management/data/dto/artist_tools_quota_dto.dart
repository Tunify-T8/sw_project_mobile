// Upload Feature Guide:
// Purpose: DTO model that represents upload-related request or response data at the API boundary.
// Used by: library_uploads_api, mock_library_uploads_api, library_uploads_mapper
// Concerns: Supporting UI and infrastructure for upload and track management.
class ArtistToolsQuotaDto {
  final String tier;
  final int uploadMinutesLimit;
  final int uploadMinutesUsed;
  final bool canReplaceFiles;

  const ArtistToolsQuotaDto({
    required this.tier,
    required this.uploadMinutesLimit,
    required this.uploadMinutesUsed,
    required this.canReplaceFiles,
  });

  factory ArtistToolsQuotaDto.fromJson(Map<String, dynamic> json) {
    return ArtistToolsQuotaDto(
      tier: (json['tier'] as String?) ?? 'free',
      uploadMinutesLimit: (json['uploadMinutesLimit'] as num?)?.toInt() ?? -1,
      uploadMinutesUsed: (json['uploadMinutesUsed'] as num?)?.toInt() ?? 0,
      canReplaceFiles: (json['canReplaceFiles'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'uploadMinutesLimit': uploadMinutesLimit,
      'uploadMinutesUsed': uploadMinutesUsed,
      'canReplaceFiles': canReplaceFiles,
    };
  }
}
