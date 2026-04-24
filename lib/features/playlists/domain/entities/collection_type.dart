/// Server-side collection type values.
/// Must match the backend's PLAYLIST / ALBUM string literals exactly.
enum CollectionType {
  playlist,
  album;

  /// Serialises to the exact string the backend expects.
  String toJson() => name.toUpperCase(); // "PLAYLIST" | "ALBUM"

  static CollectionType fromJson(String raw) {
    return switch (raw.toUpperCase()) {
      'ALBUM' => CollectionType.album,
      _ => CollectionType.playlist,
    };
  }
}
