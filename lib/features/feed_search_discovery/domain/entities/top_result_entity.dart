// ─── Top result (the big card at the top of the "All" tab) ───────────────────
enum TopResultType { track, profile, playlist, album }

class TopResultEntity {
  final String id;
  final TopResultType type;
  final String title;
  final String subtitle; // artist name, follower count, etc.
  final String? artworkUrl;

  const TopResultEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.artworkUrl,
  });
}
