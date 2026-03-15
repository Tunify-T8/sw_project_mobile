class TrackMetadata {
  final String title;
  final String genreCategory;
  final String genreSubGenre;
  final List<String> tags;
  final String description;
  final String privacy;
  final List<String> artists;
  final String? artworkPath;

  final String recordLabel;
  final String publisher;
  final String isrc;
  final bool contentWarning;
  final DateTime? scheduledReleaseDate;

  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;

  final String availabilityType;
  final List<String> availabilityRegions;
  final String licensing;

  const TrackMetadata({
    required this.title,
    required this.genreCategory,
    required this.genreSubGenre,
    required this.tags,
    required this.description,
    required this.privacy,
    required this.artists,
    this.artworkPath,
    required this.recordLabel,
    required this.publisher,
    required this.isrc,
    required this.contentWarning,
    required this.scheduledReleaseDate,
    required this.allowDownloads,
    required this.offlineListening,
    required this.includeInRss,
    required this.displayEmbedCode,
    required this.appPlaybackEnabled,
    required this.availabilityType,
    required this.availabilityRegions,
    required this.licensing,
  });
}
