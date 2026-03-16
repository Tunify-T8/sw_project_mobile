enum UploadVisibility { public, private }

enum UploadProcessingStatus { finished, processing, failed, deleted }

class UploadItem {
  final String id;
  final String title;
  final String artistDisplay;
  final String durationLabel;
  final int durationSeconds;
  final String? artworkUrl;
  final String? localArtworkPath;
  final String? localFilePath;
  final String? description;
  final List<String> tags;
  final String genreCategory;
  final String genreSubGenre;
  final UploadVisibility visibility;
  final UploadProcessingStatus status;
  final bool isExplicit;
  final String recordLabel;
  final String publisher;
  final String isrc;
  final String pLine;
  final DateTime? scheduledReleaseDate;
  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;
  final String availabilityType;
  final List<String> availabilityRegions;
  final String licensing;
  final DateTime createdAt;

  const UploadItem({
    required this.id,
    required this.title,
    required this.artistDisplay,
    required this.durationLabel,
    required this.durationSeconds,
    required this.artworkUrl,
    this.localArtworkPath,
    this.localFilePath,
    this.description,
    this.tags = const [],
    this.genreCategory = '',
    this.genreSubGenre = '',
    required this.visibility,
    required this.status,
    required this.isExplicit,
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

  bool get isPlayable => status == UploadProcessingStatus.finished;
  bool get isDeleted => status == UploadProcessingStatus.deleted;

  UploadItem copyWith({
    String? id,
    String? title,
    String? artistDisplay,
    String? durationLabel,
    int? durationSeconds,
    String? artworkUrl,
    String? localArtworkPath,
    String? localFilePath,
    String? description,
    List<String>? tags,
    String? genreCategory,
    String? genreSubGenre,
    UploadVisibility? visibility,
    UploadProcessingStatus? status,
    bool? isExplicit,
    String? recordLabel,
    String? publisher,
    String? isrc,
    String? pLine,
    DateTime? scheduledReleaseDate,
    bool? allowDownloads,
    bool? offlineListening,
    bool? includeInRss,
    bool? displayEmbedCode,
    bool? appPlaybackEnabled,
    String? availabilityType,
    List<String>? availabilityRegions,
    String? licensing,
    DateTime? createdAt,
  }) {
    return UploadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artistDisplay: artistDisplay ?? this.artistDisplay,
      durationLabel: durationLabel ?? this.durationLabel,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      localFilePath: localFilePath ?? this.localFilePath,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      genreCategory: genreCategory ?? this.genreCategory,
      genreSubGenre: genreSubGenre ?? this.genreSubGenre,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      isExplicit: isExplicit ?? this.isExplicit,
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