// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: mock_library_uploads_api, library_uploads_mapper, and 30 more upload files.
// Concerns: Multi-format support; Track visibility.
enum UploadVisibility { public, private }

enum UploadProcessingStatus { finished, processing, failed, deleted }

class UploadItem {
  final String id;
  final String title;
  final String artistDisplay;
  final String durationLabel;
  final int durationSeconds;
  final String? audioUrl;
  final String? waveformUrl;
  final List<double>? waveformBars;
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
  final String? privateToken;

  const UploadItem({
    required this.id,
    required this.title,
    required this.artistDisplay,
    required this.durationLabel,
    required this.durationSeconds,
    this.audioUrl,
    this.waveformUrl,
    this.waveformBars,
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
    this.privateToken,
  });

  bool get isPlayable => status == UploadProcessingStatus.finished;
  bool get isDeleted => status == UploadProcessingStatus.deleted;

  // ── Equality ────────────────────────────────────────────────────────────────
  // Required so Riverpod .family providers can correctly distinguish between
  // two different UploadItem instances used as keys.
  // We key on `id` — every upload gets a unique millisecond-based id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UploadItem && other.id == id);

  @override
  int get hashCode => id.hashCode;

  UploadItem copyWith({
    String? id,
    String? title,
    String? artistDisplay,
    String? durationLabel,
    int? durationSeconds,
    String? audioUrl,
    String? waveformUrl,
    List<double>? waveformBars,
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
    String? privateToken,
  }) {
    return UploadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artistDisplay: artistDisplay ?? this.artistDisplay,
      durationLabel: durationLabel ?? this.durationLabel,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      waveformUrl: waveformUrl ?? this.waveformUrl,
      waveformBars: waveformBars ?? this.waveformBars,
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
      privateToken: privateToken ?? this.privateToken,
    );
  }
}
