/// Lightweight owner summary embedded in collection responses.
/// Matches the `owner` object returned by GET /collections/:id.
class PlaylistOwnerEntity {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  const PlaylistOwnerEntity({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });
}
