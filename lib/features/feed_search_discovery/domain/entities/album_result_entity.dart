// ─── Album search result ─────────────────────────────────────────────────────
class AlbumResultEntity {
  final String id;
  final String title;
  final String artistName;
  final String? artworkUrl;
  final int trackCount;
  final int? releaseYear;

  const AlbumResultEntity({
    required this.id,
    required this.title,
    required this.artistName,
    this.artworkUrl,
    required this.trackCount,
    this.releaseYear,
  });
}
