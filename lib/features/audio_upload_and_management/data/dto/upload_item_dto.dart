class UploadItemDto {
  final String id;
  final String title;
  final List<String> artists;
  final int durationSeconds;
  final String? artworkUrl;
  final String? localArtworkPath;
  final String? localFilePath;
  final String? description;
  final List<String> tags;
  final String genreCategory;
  final String genreSubGenre;
  final String privacy;
  final String status;
  final bool contentWarning;
  final String recordLabel;
  final String publisher;
  final String isrc;
  final String pLine;
  final String? scheduledReleaseDate;
  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;
  final String availabilityType;
  final List<String> availabilityRegions;
  final String licensing;
  final String createdAt;

  const UploadItemDto({
    required this.id,
    required this.title,
    required this.artists,
    required this.durationSeconds,
    required this.artworkUrl,
    this.localArtworkPath,
    this.localFilePath,
    this.description,
    this.tags = const [],
    this.genreCategory = '',
    this.genreSubGenre = '',
    required this.privacy,
    required this.status,
    required this.contentWarning,
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
    required this.createdAt,
  });

  factory UploadItemDto.fromJson(Map<String, dynamic> json) {
    return UploadItemDto(
      id: (json['id'] ?? json['trackId'] ?? '').toString(),
      title: (json['title'] as String?) ?? '',
      artists: ((json['artists'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      artworkUrl: json['artworkUrl'] as String?,
      localArtworkPath: json['localArtworkPath'] as String?,
      localFilePath: json['localFilePath'] as String?,
      description: json['description'] as String?,
      tags: ((json['tags'] as List?) ?? const [])
          .map((e) => e.toString())
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
          .map((e) => e.toString())
          .toList(),
      licensing: (json['licensing'] as String?) ?? 'all_rights_reserved',
      createdAt:
          (json['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackId': id,
      'title': title,
      'artists': artists,
      'durationSeconds': durationSeconds,
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

  UploadItemDto copyWith({
    String? id,
    String? title,
    List<String>? artists,
    int? durationSeconds,
    String? artworkUrl,
    String? localArtworkPath,
    String? localFilePath,
    String? description,
    List<String>? tags,
    String? genreCategory,
    String? genreSubGenre,
    String? privacy,
    String? status,
    bool? contentWarning,
    String? recordLabel,
    String? publisher,
    String? isrc,
    String? pLine,
    String? scheduledReleaseDate,
    bool? allowDownloads,
    bool? offlineListening,
    bool? includeInRss,
    bool? displayEmbedCode,
    bool? appPlaybackEnabled,
    String? availabilityType,
    List<String>? availabilityRegions,
    String? licensing,
    String? createdAt,
  }) {
    return UploadItemDto(
      id: id ?? this.id,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      localFilePath: localFilePath ?? this.localFilePath,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      genreCategory: genreCategory ?? this.genreCategory,
      genreSubGenre: genreSubGenre ?? this.genreSubGenre,
      privacy: privacy ?? this.privacy,
      status: status ?? this.status,
      contentWarning: contentWarning ?? this.contentWarning,
      recordLabel: recordLabel ?? this.recordLabel,
      publisher: publisher ?? this.publisher,
      isrc: isrc ?? this.isrc,
      pLine: pLine ?? this.pLine,
      scheduledReleaseDate: scheduledReleaseDate ?? this.scheduledReleaseDate,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      offlineListening: offlineListening ?? this.offlineListening,
      includeInRss: includeInRss ?? this.includeInRss,
      displayEmbedCode: displayEmbedCode ?? this.displayEmbedCode,
      appPlaybackEnabled: appPlaybackEnabled ?? this.appPlaybackEnabled,
      availabilityType: availabilityType ?? this.availabilityType,
      availabilityRegions: availabilityRegions ?? this.availabilityRegions,
      licensing: licensing ?? this.licensing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}