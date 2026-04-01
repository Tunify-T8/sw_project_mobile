// ─── Search tab enum ──────────────────────────────────────────────────────────
enum SearchTab { all, tracks, profiles, playlists, albums }

// ─── Genre (for the idle grid) ───────────────────────────────────────────────
class SearchGenreEntity {
  final String id;
  final String label;

  /// Placeholder color used as background until artwork is available.
  /// Stored as an int (ARGB) so it stays pure Dart with no Flutter dependency.
  final int colorValue;

  /// Optional artwork URL — null until backend supplies real images.
  final String? artworkUrl;

  const SearchGenreEntity({
    required this.id,
    required this.label,
    required this.colorValue,
    this.artworkUrl,
  });
}
