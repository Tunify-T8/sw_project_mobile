// ─── Search tab enum ──────────────────────────────────────────────────────────
enum SearchTab { all, tracks, profiles, playlists, albums }

// ─── Genre (for the idle grid) ───────────────────────────────────────────────
class SearchGenreEntity {
  final String id;
  final String label;

  /// Placeholder color used as background until artwork is available.
  final int colorValue;

  /// Optional remote artwork URL — null until backend supplies real images.
  final String? artworkUrl;

  /// Optional local asset path for a genre cover image.
  ///
  /// Convention: `assets/genres/<name>.jpg`
  /// Named to match the genre exactly, for example:
  ///   hip_hop_rap.jpg   pop.jpg         chill.jpg       workout.jpg
  ///   house.jpg         at_home.jpg     study.jpg       indie.jpg
  ///   country.jpg       rock.jpg        electronic.jpg  rnb.jpg
  ///   party.jpg         techno.jpg      feel_good.jpg   healing_era.jpg
  ///   folk.jpg          soul.jpg        latin.jpg
  ///
  /// When non-null the tile and genre-detail header will show the image
  /// instead of the solid color. If the file does not exist yet the solid
  /// color is shown silently via errorBuilder — no code change needed.
  final String? imageAsset;

  const SearchGenreEntity({
    required this.id,
    required this.label,
    required this.colorValue,
    this.artworkUrl,
    this.imageAsset,
  });
}
