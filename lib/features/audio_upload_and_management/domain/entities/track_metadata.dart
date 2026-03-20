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
  final String pLine;
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
    required this.artworkPath,
    this.recordLabel = '',
    this.publisher = '',
    this.isrc = '',
    this.pLine = '',
    this.contentWarning = false,
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
}
