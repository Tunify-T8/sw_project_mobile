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
    return UploadItemDto(
      id: (json['id'] ?? json['trackId'] ?? '').toString(),
      title: (json['title'] as String?) ?? '',
      artists: ((json['artists'] as List?) ?? const [])
          .map((entry) => entry.toString())
          .toList(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      audioUrl: json['audioUrl'] as String?,
      waveformUrl: json['waveformUrl'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      localArtworkPath: json['localArtworkPath'] as String?,
      localFilePath: json['localFilePath'] as String?,
      description: json['description'] as String?,
      tags: ((json['tags'] as List?) ?? const [])
          .map((entry) => entry.toString())
          .toList(),
      genreCategory: (json['genreCategory'] as String?) ?? '',
      genreSubGenre: (json['genreSubGenre'] as String?) ?? '',
      privacy: (json['privacy'] as String?) ?? 'private',
      status: (json['status'] as String?) ?? 'finished',
      contentWarning: (json['contentWarning'] as bool?) ?? false,
      recordLabel: (json['recordLabel'] as String?) ?? '',
      publisher: (json['publisher'] as String?) ?? '',
      isrc: (json['isrc'] as String?) ?? '',
      pLine: (json['pLine'] as String?) ?? '',
      scheduledReleaseDate: json['scheduledReleaseDate'] as String?,
      allowDownloads: (json['allowDownloads'] as bool?) ?? false,
      offlineListening: (json['offlineListening'] as bool?) ?? true,
      includeInRss: (json['includeInRss'] as bool?) ?? true,
      displayEmbedCode: (json['displayEmbedCode'] as bool?) ?? true,
      appPlaybackEnabled: (json['appPlaybackEnabled'] as bool?) ?? true,
      availabilityType: (json['availabilityType'] as String?) ?? 'worldwide',
      availabilityRegions: ((json['availabilityRegions'] as List?) ?? const [])
          .map((entry) => entry.toString())
          .toList(),
      licensing: (json['licensing'] as String?) ?? 'all_rights_reserved',
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
