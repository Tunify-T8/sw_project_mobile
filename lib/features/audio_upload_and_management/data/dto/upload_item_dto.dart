// Upload Feature Guide:
// Purpose: DTO model that represents upload-related request or response data at the API boundary.
// Used by: library_uploads_api, mock_library_uploads_api, library_uploads_mapper
// Concerns: Multi-format support; Track visibility.
part 'upload_item_dto_copy_with.dart';

class UploadItemDto {
  const UploadItemDto({
    required this.id,
    required this.title,
    required this.artists,
    required this.durationSeconds,
    required this.artworkUrl,
    required this.privacy,
    required this.status,
    required this.contentWarning,
    required this.createdAt,
    this.audioUrl,
    this.waveformUrl,
    this.waveformBars,
    this.localArtworkPath,
    this.localFilePath,
    this.description,
    this.tags = const [],
    this.genreCategory = '',
    this.genreSubGenre = '',
    this.recordLabel = '',
    this.publisher = '',
    this.isrc = '',
    this.pLine = '',
    this.scheduledReleaseDate,
    this.allowDownloads = false,
    this.offlineListening = true,
    this.includeInRss = true,
    this.displayEmbedCode = true,
    this.appPlaybackEnabled = true,
    this.availabilityType = 'worldwide',
    this.availabilityRegions = const [],
    this.licensing = 'all_rights_reserved',
  });

  final String id;
  final String title;
  final String privacy;
  final String status;
  final String recordLabel;
  final String publisher;
  final String isrc;
  final String pLine;
  final String availabilityType;
  final String licensing;
  final String createdAt;
  final List<String> artists;
  final List<String> tags;
  final List<String> availabilityRegions;
  final int durationSeconds;
  final String? audioUrl;
  final String? waveformUrl;
  final List<double>? waveformBars;
  final String? artworkUrl;
  final String? localArtworkPath;
  final String? localFilePath;
  final String? description;
  final String? scheduledReleaseDate;
  final String genreCategory;
  final String genreSubGenre;
  final bool contentWarning;
  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;

  factory UploadItemDto.fromJson(Map<String, dynamic> json) {
    final availability = _asMap(json['availability']);
    final licensingData = _asMap(json['licensing']);
    final permissions = _asMap(json['permissions']);
    final parsedGenre = _parseGenre(
      (json['genre'] as String?) ?? (json['genreCategory'] as String?),
    );

    final durationRaw = json['durationSeconds'] ?? json['duration'] ?? 0;
    final artworkRaw = json['artworkUrl'] ?? json['thumbnailUrl'];
    final privacyRaw =
        (json['privacy'] as String?) ??
        (json['visibility'] as String?) ??
        'private';
    final statusRaw =
        (json['status'] as String?) ??
        (json['transcodingStatus'] as String?) ??
        'finished';

    return UploadItemDto(
      id: (json['id'] ?? json['trackId'] ?? '').toString(),
      title: (json['title'] as String?) ?? '',
      artists: _parseArtists(json),
      durationSeconds: (durationRaw as num?)?.toInt() ?? 0,
      audioUrl: json['audioUrl'] as String?,
      waveformUrl: json['waveformUrl'] as String?,
      waveformBars: (json['waveformBars'] as List?)
          ?.map((entry) => (entry as num?)?.toDouble())
          .whereType<double>()
          .toList(),
      artworkUrl: artworkRaw as String?,
      localArtworkPath: json['localArtworkPath'] as String?,
      localFilePath: json['localFilePath'] as String?,
      description: json['description'] as String?,
      tags: ((json['tags'] as List?) ?? const [])
          .map((entry) => entry.toString())
          .toList(),
      genreCategory: (json['genreCategory'] as String?) ?? parsedGenre.$1,
      genreSubGenre: (json['genreSubGenre'] as String?) ?? parsedGenre.$2,
      privacy: privacyRaw,
      status: statusRaw,
      contentWarning: (json['contentWarning'] as bool?) ?? false,
      recordLabel: (json['recordLabel'] as String?) ?? '',
      publisher: (json['publisher'] as String?) ?? '',
      isrc: (json['isrc'] as String?) ?? '',
      pLine: (json['pLine'] as String?) ?? '',
      scheduledReleaseDate: json['scheduledReleaseDate'] as String?,
      allowDownloads:
          (json['allowDownloads'] as bool?) ??
          (permissions?['enableDirectDownloads'] as bool?) ??
          false,
      offlineListening:
          (json['offlineListening'] as bool?) ??
          (permissions?['enableOfflineListening'] as bool?) ??
          true,
      includeInRss:
          (json['includeInRss'] as bool?) ??
          (permissions?['includeInRSS'] as bool?) ??
          true,
      displayEmbedCode:
          (json['displayEmbedCode'] as bool?) ??
          (permissions?['displayEmbedCode'] as bool?) ??
          true,
      appPlaybackEnabled:
          (json['appPlaybackEnabled'] as bool?) ??
          (permissions?['enableAppPlayback'] as bool?) ??
          true,
      availabilityType:
          (json['availabilityType'] as String?) ??
          (availability?['type'] as String?) ??
          'worldwide',
      availabilityRegions:
          ((json['availabilityRegions'] as List?) ??
                  (availability?['regions'] as List?) ??
                  const [])
              .map((entry) => entry.toString())
              .toList(),
      licensing:
          (json['licensing'] as String?) ??
          (licensingData?['type'] as String?) ??
          'all_rights_reserved',
      createdAt:
          (json['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trackId': id,
    'title': title,
    'artists': artists,
    'durationSeconds': durationSeconds,
    'audioUrl': audioUrl,
    'waveformUrl': waveformUrl,
    'waveformBars': waveformBars,
    'artworkUrl': artworkUrl,
    'localArtworkPath': localArtworkPath,
    'localFilePath': localFilePath,
    'description': description,
    'tags': tags,
    'genreCategory': genreCategory,
    'genreSubGenre': genreSubGenre,
    'privacy': privacy,
    'status': status,
    'contentWarning': contentWarning,
    'recordLabel': recordLabel,
    'publisher': publisher,
    'isrc': isrc,
    'pLine': pLine,
    'scheduledReleaseDate': scheduledReleaseDate,
    'allowDownloads': allowDownloads,
    'offlineListening': offlineListening,
    'includeInRss': includeInRss,
    'displayEmbedCode': displayEmbedCode,
    'appPlaybackEnabled': appPlaybackEnabled,
    'availabilityType': availabilityType,
    'availabilityRegions': availabilityRegions,
    'licensing': licensing,
    'createdAt': createdAt,
  };
}

List<String> _parseArtists(Map<String, dynamic> json) {
  final list = json['artists'];
  if (list is List && list.isNotEmpty) {
    return list
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
  }

  final singular = json['artist'];
  if (singular is String && singular.trim().isNotEmpty) {
    return [singular.trim()];
  }

  if (singular is Map<String, dynamic>) {
    final value = (singular['name'] ?? singular['username'] ?? singular['id'])
        ?.toString()
        .trim();
    if (value != null && value.isNotEmpty) {
      return [value];
    }
  }

  return const [];
}

Map<String, dynamic>? _asMap(dynamic value) {
  return value is Map<String, dynamic> ? value : null;
}

(String, String) _parseGenre(String? rawGenre) {
  final normalized = rawGenre?.trim() ?? '';
  if (normalized.isEmpty) {
    return ('', '');
  }

  final parts = normalized.split('_');
  if (parts.length < 2) {
    return (normalized, '');
  }

  final category = parts.first;
  final subGenre = parts.skip(1).join('_');
  return (category, subGenre);
}
